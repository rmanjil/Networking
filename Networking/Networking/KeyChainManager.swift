//
//  KeyChainManager.swift
//  PracticalAction
//
//  Created by manjil on 29/03/2023.
//

import Foundation
import SwiftKeychainWrapper

class KeyChainManager {
    
    //MARK: Properties
    public static let standard = KeyChainManager()
    
    //MARK: Functions
    public func set<T: Codable>(object: T, forKey key: String) {
        let encoded = KeyChainManager.standard.encode(object: object)
        KeychainWrapper.standard[KeychainWrapper.Key(rawValue: key)] = encoded
    }
    
    //GET ANY TYPE OF CODABLE OBJECT IN KEYCHAIN
    public func retrieve<T: Codable>(type: T.Type, forKey key: String) -> T? {
        let dataObject = KeychainWrapper.standard.data(forKey: key) ?? Data()
        return KeyChainManager.standard.decode(json: dataObject, as: type)
    }
    
    //CHCEK IF ANY TYPE OF CODABLE OBJECT IN KEYCHAIN IS AVAILABLE
    public func isAvailable<T: Codable> (type: T.Type, forKey key: String) -> Bool {
        let decoded = KeyChainManager.standard.retrieve(type: T.self, forKey: key)
        return decoded != nil
    }
    
    //CLEAR ANY TYPE OF CODABLE OBJECT IN KEYCHAIN IS AVAILABLE
    public func clear(_ key: String? = nil) {
        if let key = key {
            KeychainWrapper.standard.removeObject(forKey: key)
        } else {
            KeychainWrapper.standard.removeAllKeys()
        }
    }
    
}

extension KeyChainManager {
    
    private func encode<T: Codable>(object: T) -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(object)
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func decode<T: Decodable>(json: Data, as clazz: T.Type) -> T? {
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: json)
            return data
        } catch {
            print("An error occurred while parsing JSON")
        }
        return nil
    }
}

