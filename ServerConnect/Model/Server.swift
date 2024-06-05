//
//  Server.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 11/12/2021.
//

import Cocoa

struct Server: Codable {
    
    enum ConnectionMethod: String, Codable {
        case afp
        case smb
        case web
    }
    
    /*
     Connection method
     */
    var method: ConnectionMethod = .smb
    
    
    /*
     Connection address
     */
    var address: String
    
    /*
     Where the server is mounted on the local filesystem
     */
    var mountPoint: String?
    
    /*
     Name of the server, shown to the user
     */
    var name: String
    
    /*
     Optional description of the server
     */
    var description: String?
    var username: String?
    var paths: [Path]
    var ldapUrl: String?
    
    func getUrl() throws ->  URL  {
        var urlString = ""
        switch self.method {
        case .afp:
            urlString.append("afp://")
        case .smb:
            urlString.append("smb://")
        case .web:
            urlString.append("https://")
        }
        
        urlString.append(self.address)
        return URL.init(string: urlString)!
    }
    
    
    
}
