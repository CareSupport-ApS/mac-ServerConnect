
import Foundation
import NetFS

enum ShareMountError: Error {
    case InvalidURL(input: String)
    case MountpointInaccessible
    case InvalidMountOptions
}

enum MountOption {
    case NoBrowse
    case ReadOnly
    case AllowSubMounts
    case SoftMount
    case MountAtMountDirectory
    
    case Guest
    case AllowLoopback
    case NoAuthDialog
    case AllowAuthDialog
    case ForceAuthDialog
}

typealias NetFSMountCallback = (Int32, UnsafeMutableRawPointer?, CFArray?) -> Void
typealias MountCallbackHandler = (Int32, URL?, [String]?) -> Void;

protocol ShareDelegate {
    func shareWillMount(url: URL) -> Void
    func shareDidMount(url: URL, at paths: [String]?) -> Void
    func shareMountingDidFail(for url: URL, withError: Int32) -> Void
}

fileprivate func processOptionsForNetFS(options: [MountOption]) throws -> (NSMutableDictionary, NSMutableDictionary) {
    let openOptions: NSMutableDictionary = NSMutableDictionary()
    let mountOptions: NSMutableDictionary = NSMutableDictionary()
    
    for opt in options {
        switch opt {
            
        // mount_options
        case .NoBrowse:
            if let existingValue = mountOptions.value(forKey: kNetFSMountFlagsKey) {
                mountOptions[kNetFSMountFlagsKey] = existingValue as! Int32 | MNT_DONTBROWSE
            } else {
                mountOptions[kNetFSMountFlagsKey] = MNT_DONTBROWSE
            }
        case .ReadOnly:
            if let existingValue = mountOptions.value(forKey: kNetFSMountFlagsKey) {
                mountOptions[kNetFSMountFlagsKey] = existingValue as! Int32 | MNT_RDONLY
            } else {
                mountOptions[kNetFSMountFlagsKey] = MNT_RDONLY
            }
        case .AllowSubMounts:
            mountOptions[kNetFSAllowSubMountsKey] = true
        case .SoftMount:
            mountOptions[kNetFSSoftMountKey] = true
        case .MountAtMountDirectory:
            mountOptions[kNetFSMountAtMountDirKey] = true
            
        // open_options
        case .Guest:
            openOptions[kNetFSUseGuestKey] = true
        case .AllowLoopback:
            openOptions[kNetFSAllowLoopbackKey] = true
        case .NoAuthDialog:
            openOptions[kNAUIOptionKey] = kNAUIOptionNoUI
        case .AllowAuthDialog:
            openOptions[kNAUIOptionKey] = kNAUIOptionAllowUI
        case .ForceAuthDialog:
            openOptions[kNAUIOptionKey] = kNAUIOptionForceUI
        }
    }
    
    return (openOptions, mountOptions)
}


class Share {
    let url: URL
    var mountPoint: String = "/Volumes"
    var username: String?
    var password: String?
    fileprivate var asyncRequestId: AsyncRequestID?
    public var delegate: ShareDelegate?
    
    init(_ url: URLComponents) throws {
        guard let url = url.url else {
    
            throw ShareMountError.InvalidURL(input: url.string ?? "")
        }
        print(url.absoluteString)
        self.url = url
    }

    
    public func cancelMounting() {
        NetFSMountURLCancel(self.asyncRequestId)
    }
    
    static func cancelMounting(id requestId: AsyncRequestID) {
        NetFSMountURLCancel(requestId)
    }
    
    public func mount() throws {
        let mountDirectoryURL = URL(fileURLWithPath: self.mountPoint)
        let operationQueue = OperationQueue.main
        
        let mountReportBlock: NetFSMountCallback = {
            status, asyncRequestId, mountedDirs in
            
            let mountedDirectories = mountedDirs as! [String]? ?? nil
            
            if (status != 0) {
                self.delegate?.shareMountingDidFail(for: self.url, withError: status)
            } else {
                self.delegate?.shareDidMount(url: self.url, at: mountedDirectories)
            }
        }
        
        NetFSMountURLAsync(url as CFURL,
                           mountDirectoryURL as CFURL,
                           username as CFString?,
                           password as CFString?,
                           nil,
                           nil,
                           &self.asyncRequestId,
                           operationQueue.underlyingQueue,
                           mountReportBlock)
        self.delegate?.shareWillMount(url: url)
    }
    
    public func mount(options: [MountOption]?) async throws -> String? {
        let mountDirectoryURL = URL(fileURLWithPath: self.mountPoint)
        let operationQueue = OperationQueue.main
        
        var openOptions: NSMutableDictionary
        var mountOptions: NSMutableDictionary
        
        if options != nil {
            (openOptions, mountOptions) = try processOptionsForNetFS(options: options!)
        } else {
            openOptions = NSMutableDictionary()
            mountOptions = NSMutableDictionary()
        }
        
        var mountedVolumes: Unmanaged<CFArray>?
        
        let rc = NetFSMountURLSync(url as CFURL,
                           mountDirectoryURL as CFURL,
                           username as CFString?,
                           password as CFString?,
                           openOptions as CFMutableDictionary,
                           mountOptions as CFMutableDictionary,
                                   &mountedVolumes)
        
    
                        switch rc {
                        case 0, 17:
                            let nsarray = (mountedVolumes?.takeRetainedValue() as? [String])?.first
                          return nsarray
                        case 2:
                            throw MounterError.doesNotExist
                        case 60:
                            throw MounterError.timedOutHost
                        case 64:
                            throw MounterError.hostIsDown
                        case 65:
                            throw MounterError.noRouteToHost
                        case 80:
                            throw MounterError.authenticationError
                        case -6003:
                            throw MounterError.shareDoesNotExist
                        default:
                            throw MounterError.unknownReturnCode

                }
    }
}
