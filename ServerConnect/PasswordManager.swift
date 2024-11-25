//
//  PasswordManager.swift
//  Network Share Mounter
//
//  Created by Longariva, Gregor (RRZE) on 20.11.23.
//  Copyright © 2024 Regionales Rechenzentrum Erlangen. All rights reserved.
//

import Foundation
import Security
import Haversack


struct Credentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case malformedShare
    case unexpectedPasswordData
    case undefinedError
    case errorRemovingEntry
    case errorRetrievingPassword
    case errorAccessingPassword
    case errorWithStatus(status: OSStatus)
}

class KeychainManager {
    
    
    static let shared = KeychainManager()
    private let haversack = Haversack()
    private init() {}
    

    private func makeEntity(share shareURL: URL, username: String) throws -> InternetPasswordEntity  {
        let entity = InternetPasswordEntity()
        
        let host = shareURL.host
        let urlScheme = shareURL.scheme
        
        switch urlScheme {
        case "https":
            entity.protocol = .HTTPS
        case "afp":
            entity.protocol = .AFP
        case "smb":
            entity.protocol = .SMB
        default:
            entity.protocol = .HTTPS
        }
        
        entity.server = host
        entity.account = username
        entity.label = "ServerConnect: \(shareURL.host ?? "")"
    
        return entity
    }
    
    private func makeQuery(server: String, accountName: String) -> InternetPasswordQuery {
        return InternetPasswordQuery(server: server).matching(account: accountName)
    }
    
    
    func saveCredential(forShare share: URL, withUsername username: String, andPassword password: String) throws {
        do {
            try haversack.delete(where: makeQuery(server: share.host ?? "", accountName: username), treatNotFoundAsSuccess: true)
            
            
            let entity = try makeEntity(share: share, username: username)
            entity.description = "Created by the utility app, ServerConnect, created by CareSupport ApS"
            entity.passwordData = password.data(using: String.Encoding.utf8)!
            
           
            try haversack.save(entity, itemSecurity: ItemSecurity.init().retrievable(when: .simple(.unlockedPasscodeSetThisDeviceOnly))
                               , updateExisting: true)
        } catch {
            print("Keychain save error: \(error.localizedDescription)")
            throw KeychainError.undefinedError
        }
    }
    
    
    /// retrieve a password from the keychain
    /// - Parameter forShare: ``URL`` name of the share
    /// - Parameter withUsername: ``String`` login for share
    func retrievePassword(forShare share: URL, withUsername username: String) throws -> String? {
        do {
            let query = makeQuery(server: share.host ?? "", accountName: username).matching(label: "ServerConnect: \(share.host ?? "")").returning([.attributes, .persistantReference])
            let result = try haversack.first(where: query.returning([.all]))
            
           if let parsedData = result.passwordData  {
                return String(data: parsedData, encoding: .utf8) ?? ""
            }
        } catch {
            print("Keychain retrieve error: \(error.localizedDescription)")
            throw KeychainError.errorRetrievingPassword
        }
        return nil
    }
    
   
}


// MARK: - Helper extensions to extract data from CFArray and Dictionaries
extension CFArray {
  func toSwiftArray<T>() -> [T] {
    let array = Array<AnyObject>(_immutableCocoaArray: self)
    return array.compactMap { $0 as? T }
  }
}

// MARK: - Helper extenstion to retrieve username - password pair form dictionary
extension Dictionary where Key == String, Value == Any {
  var accountPasswordPair: (username: String, password: String)? {

    guard
      let username = self[kSecAttrAccount as String] as? String,
      let password = self[kSecValueData as String] as? Data
      else {
        return nil
    }
    return (username, String(data: password, encoding: .utf8) ?? "")
  }
}
