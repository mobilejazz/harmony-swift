//
// Copyright 2017 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Security

public class SecureKey {
    
    public let identifier : String
    public let length : size_t
    
    public init(identifier: String, length: size_t = 64) {
        self.identifier = identifier
        self.length = length
    }
    
    // Arguments for the keychain queries
    private let kSecClassStr = NSString(format: kSecClass)
    private let kSecClassKeyStr = NSString(format: kSecClassKey)
    private let kSecAttrApplicationTagStr = NSString(format: kSecAttrApplicationTag)
    private let kSecAttrKeySizeInBitsStr = NSString(format: kSecAttrKeySizeInBits)
    private let kSecReturnDataStr = NSString(format: kSecReturnData)
    private let kSecAttrAccessibleStr = NSString(format: kSecAttrAccessible)
    private let kSecAttrAccessibleAlwaysStr = NSString(format: kSecAttrAccessibleAlways)
    private let kSecValueDataStr = NSString(format: kSecValueData)
    
    @discardableResult
    public func reset() -> Bool{
         if let tag = identifier.data(using: String.Encoding.utf8) {
            var keyData = Data(count: length)
            let result = keyData.withUnsafeMutableBytes({ (pointer) -> OSStatus in
                return SecRandomCopyBytes(kSecRandomDefault, keyData.count, pointer)
            })
            
            if result == -1 {
                NSLog("Error executing SecRandomCopyBytes()")
            }
            
            let query = NSDictionary(objects:[kSecClassKeyStr, tag],
                                     forKeys:[kSecClassStr, kSecAttrApplicationTagStr])
            
            let attributesToUpdate = NSDictionary(objects:[keyData],
                                                  forKeys:[kSecValueDataStr])
            
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            if status == errSecSuccess {
                return true
            }
        }
        
        return false
    }
    
    @discardableResult
    public func clear() -> Bool {
        if let tag = identifier.data(using: String.Encoding.utf8) {
            let query = NSDictionary(objects:[kSecClassKeyStr, tag],
                                     forKeys: [kSecClassStr, kSecAttrApplicationTagStr])
            
            let status = SecItemDelete(query as CFDictionary)
            if status == errSecSuccess {
                return true
            }
        }
        
        return false
    }
    
    public func key() -> Data? {
        if let tag = identifier.data(using: String.Encoding.utf8) {
            let query = NSDictionary(objects:[kSecClassKeyStr, tag, length, true],
                                     forKeys: [kSecClassStr, kSecAttrApplicationTagStr, kSecAttrKeySizeInBitsStr, kSecReturnDataStr])
            
            var dataRef : CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
            
            if status == errSecSuccess {
                let data = dataRef as? Data
                return data
            } else if status == -25308 { // errKCInteractionNotAllowed
                // If reading fails because app is not allowed (device locked)
                // Fix cannot be applied because we cannot read the current keychain item.
                NSLog("Failed to fetch Keychain because the device is locked.")
            } else {
                // If no pre-existing key from this application
                
                var keyData = Data(count: length)
                let result = keyData.withUnsafeMutableBytes({ (pointer) -> OSStatus in
                    return SecRandomCopyBytes(kSecRandomDefault, keyData.count, pointer)
                })
                
                if result == -1 {
                    NSLog("Error executing SecRandomCopyBytes()")
                }
                
                let query = NSDictionary(objects:[kSecClassKeyStr, tag, length, kSecAttrAccessibleAlwaysStr, keyData],
                                         forKeys:[kSecClassStr, kSecAttrApplicationTagStr, kSecAttrKeySizeInBitsStr, kSecAttrAccessibleStr, kSecValueDataStr])
                
                let status = SecItemAdd(query as CFDictionary, nil)
                
                if status != errSecSuccess {
                    NSLog("Failed to insert key data with error: \(status)")
                    return nil
                } else {
                    return keyData
                }
            }
        }
        
        return nil
    }
}
