//
//  Path.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 11/12/2021.
//
import Foundation
import Cocoa

struct Path: Codable {
    var name: String
    var path: String
    var description: String?
    
    /*
     If the local path is not alligned with the name or path property, use this property
     */
    var localPath: String?
    
    

    func localPath(server: Server) -> String {
        switch server.method {
        case .web:
            return NSString(string: server.mountPoint ?? "" + "/\(name)").expandingTildeInPath + "/\(localPath ?? name)"
        default:
            if let localPath = localPath {
                return "\(server.mountPoint ?? "/Volumes")/\(localPath)"
            } else if let decodedPath = path.split(separator: "/").last?.removingPercentEncoding {
               return "\(server.mountPoint ?? "/Volumes")/\(decodedPath)"
            }
        }
        return ""
    }
    
    func isMounted(server: Server) -> Bool {
        let localPath = localPath(server: server)
        // check if mount is already open
        return FileManager.default.fileExists(atPath: localPath)
    }
    
    func showInFinder(server: Server) {
        NSWorkspace.shared.open(URL(fileURLWithPath: localPath(server: server)))
    }
}
