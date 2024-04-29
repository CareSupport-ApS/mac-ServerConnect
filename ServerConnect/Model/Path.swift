//
//  Path.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 11/12/2021.
//

import Foundation

struct Path: Codable {
    var name: String
    var path: String
    var description: String?
    
    var mountPath: String? {
        if let decodedPath = path.split(separator: "/").last?.removingPercentEncoding {
            return  "/Volumes/\(decodedPath)"
        }
        return nil
    }
}
