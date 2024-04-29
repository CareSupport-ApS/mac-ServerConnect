//
//  DefaultsHelper.swift
//  ServerConnect
//
//  Created by Emil Møller Lind on 11/12/2021.
//

import Foundation

struct DefaultsHelper {
    
    static func getServers() -> [Server]  {
        do {
            let defaults = UserDefaults.standard
            guard let dict = defaults.array(forKey: "servers") as? [[String: Any]] else {return []}
            guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {return []}
            let servers: [Server] = try JSONDecoder().decode([Server].self, from: data)
            return servers
        } catch {
            print(error)
            return []
        }
       
     
    }
        
    static func companyName() -> String {
        return UserDefaults.standard.string(forKey: "companyName") ?? "CareSupport ApS"
    }
    
    static func logoUrl() -> String {
        return UserDefaults.standard.string(forKey: "logoUrl") ?? "https://caresupport.dk/wp-content/uploads/2022/06/Screenshot-2022-06-09-at-11.49.07.png"
    }
    
    static func subtitle() -> String {
        return UserDefaults.standard.string(forKey: "subtitle") ?? "Links til dataopbevaring"
    }
    
    static func helpURL() -> String? {
        return UserDefaults.standard.string(forKey: "helpURL")
    }
}
