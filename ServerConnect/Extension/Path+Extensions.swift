//
//  Share+Extensions.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 06/04/2024.
//

import Cocoa
import Foundation


extension Path {
    
    func isMounted() -> Bool {
        // check if mount is already open
        
        if let decodedPath = path.split(separator: "/").last?.removingPercentEncoding {
            let volumePath = "/Volumes/\(decodedPath)"
                return FileManager.default.fileExists(atPath: volumePath)
        }
        return false
    }
    
    func showInFinder() {
        if let decodedPath = path.split(separator: "/").last?.removingPercentEncoding {
            let volumePath = "/Volumes/\(decodedPath)"
                FileManager.default.fileExists(atPath: volumePath)
            NSWorkspace.shared.open(URL(fileURLWithPath: volumePath))
        }
    }
    
}
