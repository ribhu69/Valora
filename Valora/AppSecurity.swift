//
//  AppSecurity.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 21/09/24.
//

import Foundation
import CryptoKit

class AppSecurity {
    
    static let shared = AppSecurity()
    private init() {
        
    }
    // Convert a string to a symmetric key using SHA-256 hashing
    func generateSymmetricKey(from password: String) -> SymmetricKey {
        let passwordData = Data(password.utf8)
        let hash = SHA256.hash(data: passwordData)
        return SymmetricKey(data: hash)
    }

    // Encrypt function using AES-GCM
    func encrypt(plainText: String) throws -> Data {
        let passWord = retrieveValueFromKeychain(forKey: APP_MASTER_KEY)!
        let key = generateSymmetricKey(from: passWord)
        let data = Data(plainText.utf8)
        
        // Generate a random nonce
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    // Decrypt function using AES-GCM
    func decrypt(encryptedData: Data) throws -> String {
        let passWord = retrieveValueFromKeychain(forKey: APP_MASTER_KEY)!

        let key = generateSymmetricKey(from: passWord)
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8) ?? ""
    }

    
    func retrieveValueFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            if let data = item as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            }
        } else {
            print("Error retrieving value: \(status)")
        }
        
        return nil
    }
    
    func storeValueInKeychain(value: String, forKey key: String) -> Bool {
        let valueData = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: valueData
        ]
        
        // Add the item to the keychain.
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("Value stored successfully!")
            return true
        } else {
            print("Error storing value: \(status)")
            return false
        }
    }
}
