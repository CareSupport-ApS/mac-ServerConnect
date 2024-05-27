//
//  LoginViewController.swift
//  ServerConnect.24
//
//  Created by Emil Møller Lind on 18/01/2024.
//

import Cocoa
import PerfectLDAP
import NetFS


struct LoginError: Error {
let title: String
}

class LoginViewController: NSViewController {
    var receivedServer: Server!
    var receivedPath: Path!
    
    private var tasks: Set<Task<Void, Never>> = []
    
    @IBOutlet weak var emailTextField: NSTextField!
    
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    @IBOutlet weak var rememberToggle: NSButton!
    
    @IBAction func loginButtonPressed(_ sender: NSButton) {
        let task = Task {
                await login()
            }
            tasks.insert(task)
    }
    @IBAction func cancelButton(_ sender: NSButton) {
        dismissViewController()
        
    }
    
    override func viewDidDisappear() {
        for task in tasks {
              task.cancel()
          }
          tasks.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if receivedServer.method == .web {
            let fullPath = receivedServer.address.hasSuffix("/") ? receivedServer.address + receivedPath.path : receivedServer.address  + "/" + receivedPath.path
               if let url = URL(string: fullPath) {
                   NSWorkspace.shared.open(url)
               }
            dismissViewController()
        }
        
        
        if let email = receivedServer.username {
            emailTextField.stringValue = email
                        
            do  {
                if let password = try KeychainManager().retrievePassword(forShare: receivedServer.getUrl(), withUsername: email) {
                    passwordTextField.stringValue = password
                    let shiftHeld = NSEvent.modifierFlags.contains(.shift)
                      if !shiftHeld {
                          let task = Task {
                                await login()
                            }
                            tasks.insert(task)
                      }
                }
            } catch {
                debugPrint(error)
            }
        }
        
        // Do view setup here.
    }
    
    private func dismissViewController() {
            self.dismiss(nil)
        }
    
    private func login() async {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        
        do {
            if (rememberToggle.state == .on) {
                try KeychainManager().saveCredential(forShare: receivedServer.getUrl(), withUsername: emailTextField.stringValue, andPassword: passwordTextField.stringValue)
            } else {
//                try PasswordManager().removeCredential(forShare: serverURL(server: receivedServer), withUsername: receivedServer.username ?? "")
            }
        } catch {
            debugPrint(error)
        }
        showOverlay()
        
        // Perform an LDAP Bind request, if this is asked by the client. Only perform the rest of the login if this LDAP Bind request works.
        if let ldapUrl = receivedServer.ldapUrl {
            let success = await performLdapBind(ldapUrl: ldapUrl)
            if (!success) {return }
        }
        
        let openServerResult = await openServer(server: receivedServer, path: receivedPath, username: emailTextField.stringValue , password: passwordTextField.stringValue)
        
        if (openServerResult) {
            dismissViewController()
        }
    }
    
    private func performLdapBind(ldapUrl: String) async -> Bool {
        do {
            // first create a connection
            let connection = try LDAP(url: "ldap://\(ldapUrl)")
            connection.timeout = 8
            connection.limitation = 3
            // setup login info
            let credential = LDAP.Login(binddn: "uid=\(emailTextField.stringValue)", password: passwordTextField.stringValue)
            // login in a separated thread
            let success: Bool = try await withCheckedThrowingContinuation {  continuation in
                        connection.login(info: credential) { err in
                                          // Check for cancellation right after the async operation completes
                                          if Task.isCancelled {
                                              continuation.resume(throwing: CancellationError())
                                              return
                                          }
                            
                            if let err = err {
                                continuation.resume(throwing: LoginError.ldapBindFailed(message: err))
                            } else {
                                continuation.resume(returning: true)
                            }
                        }
                    }
            return success
        } catch {
            if Task.isCancelled {
                return false
            }
            showErrorDialog(error: error)
            return false
        }
    }
    
    enum LoginError: Error {
        case ldapBindFailed(message: String)
    }
    
    func showErrorDialog(error: Error) {
        let title: String
        let message: String
        
        switch error {
            case let loginError as LoginError:
                switch loginError {
                case .ldapBindFailed(let errorMessage):
                    title = "Kunne ikke binde til LDAP serveren"
                    message = errorMessage
                }

        case let mountError as MounterError:
            title = "Mounting error"
            message = mountError.localizedDescription
        case let shareMountError as ShareMountError:
            title = "Fejl - ShareMountError"
            switch shareMountError {
            case .InvalidURL(input: let input):
                message = "Invalid URL\n\n\(input)"
            case .MountpointInaccessible:
                message = "Mount point inaccessible"
            case .InvalidMountOptions:
                message = "Invalid mount options"
            }
            
        default:
                title = "Fejl"
            message = error.localizedDescription
            }
        
        
        overlayView?.removeFromSuperview()
        overlayView = nil
        
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        
        // Show the alert on the main thread, as UI updates must be on the main thread
        DispatchQueue.main.async {
            alert.runModal()
        }
    }
    

    var overlayView: NSView?

    func showOverlay() {
        // Create the overlay view
        overlayView = NSView(frame: self.view.bounds)
        overlayView?.wantsLayer = true
        overlayView?.layer?.backgroundColor = NSColor.clear.cgColor

        // Create and add the blur effect
        let visualEffectView = NSVisualEffectView(frame: self.view.bounds)
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .hudWindow // Adjust material for desired effect
        overlayView?.addSubview(visualEffectView)

        // Create and add the activity indicator
        let activityIndicator = NSProgressIndicator()
        activityIndicator.style = .spinning
        activityIndicator.controlSize = .regular
        activityIndicator.startAnimation(self)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        overlayView?.addSubview(activityIndicator)

        // Center the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor)
        ])

        // Add the overlay view to the main view
        self.view.addSubview(overlayView!)
    }
    
    private func openServer(server: Server, path: Path, username: String, password: String) async -> Bool {
        var urlComponents = URLComponents()
                
        switch server.method {
        case .afp:
            urlComponents.scheme = "afp"
        case .smb, .web:
            urlComponents.scheme = "smb"
        }

        urlComponents.host = server.address
        
        let decodedPath = path.path.removingPercentEncoding ?? path.path

        urlComponents.path = "/" + decodedPath

      
           do {
               let share = try Share(urlComponents)
              share.username = username
               share.password = password
               if let mountPath = server.mountPoint {
                   share.mountPoint = mountPath
               }
               
               let result = try await share.mount(options: [.AllowLoopback, .AllowSubMounts, .NoAuthDialog])
               if let nResult = result {
                   path.showInFinder(server: server)
               }
               return true
           } catch {
               showErrorDialog(error: error)
               return false
           }
       }
}
