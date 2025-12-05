//
//  KeychainManager.swift
//  AccountBook
//
//  Created by 김정원 on 12/5/25.
//
import Security
import Foundation

class KeychainManager {
    static let shared = KeychainManager()
    private init() { }
    
    let service: String = "com.cocoral.AccountBook"
    
    func save(value: String, forKey: String) -> Bool {
        let data = value.data(using: .utf8)!
        let account = forKey
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func match(value: String, forKey: String) -> Bool {
        let account = forKey
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            print("Load Password: Fail")
            return false
        }
        guard let data = item as? Data else {
            print("match: Type casting failed")
            return false
        }
        let password = String(data: data, encoding: .utf8)
        
        return password == value
    }
    
    func update(value: String, forKey: String) -> Bool {
        let data = value.data(using: .utf8)!
        let account = forKey
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        let attr: [CFString: Any] = [
            kSecValueData: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attr as CFDictionary)
        return status == errSecSuccess
    }
    
    func delete(forKey: String) -> Bool {
        let account = forKey
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
