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
    
    var method: ConnectionMethod = .smb
    var address: String
    var name: String
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
