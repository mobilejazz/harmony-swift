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

///
/// Stores securely inside the Keychain an auto-generated data blob (aka. Key).
///
public class SecureKey {
    
    /// Arguments for the keychain queries
    private struct kSec {
        static let `class`              = NSString(format: kSecClass)
        static let classKey             = NSString(format: kSecClassKey)
        static let attrApplicationTag   = NSString(format: kSecAttrApplicationTag)
        static let attrKeySizeInBits    = NSString(format: kSecAttrKeySizeInBits)
        static let returnData           = NSString(format: kSecReturnData)
        static let attrAccessible       = NSString(format: kSecAttrAccessible)
        static let attrAccessibleAlways = NSString(format: kSecAttrAccessibleAlways)
        static let valueData            = NSString(format: kSecValueData)
    }
    
    /// The key identifier
    public let identifier : String
    
    /// The key length
    public let length : size_t
    
    /// Main initializer
    ///
    /// - Parameters:
    ///   - identifier: The key identifier
    ///   - length: The key length. Default value is 64.
    public init(identifier: String, length: size_t = 64) {
        self.identifier = identifier
        self.length = length
    }
    
    /// Generates a new key and stores it inside the keychain.
    ///
    /// - Throws: CoreError.OSStatusFailure if fails.
    public func reset() throws {
        guard let tag = identifier.data(using: String.Encoding.utf8) else {
            throw CoreError.Failed("Failed to convert the SecureKey identifier to data")
        }
        
        guard let keyData = Data(randomOfLength: UInt(length)) else {
            throw CoreError.Failed("Failed to generate random key")
        }
        
        let query = NSDictionary(objects:[kSec.classKey, tag],
                                 forKeys:[kSec.class, kSec.attrApplicationTag])
        
        let attributesToUpdate = NSDictionary(objects:[keyData],
                                              forKeys:[kSec.valueData])
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        guard status == errSecSuccess else {
            throw CoreError.OSStatusFailure(status)
        }
    }
    
    /// Removes the stored key from the keychain.
    ///
    /// - Throws: CoreError.OSStatusFailure if fails.
    public func clear() throws {
        guard let tag = identifier.data(using: String.Encoding.utf8) else {
            throw CoreError.Failed("Failed to convert the SecureKey identifier to data")
        }
        
        let query = NSDictionary(objects:[kSec.classKey, tag],
                                 forKeys: [kSec.class, kSec.attrApplicationTag])
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw CoreError.OSStatusFailure(status)
        }
    }
    
    /// Returns the key.
    /// Note that if there is no key previously stored, this method will generate a new key.
    ///
    /// - Returns: The key
    /// - Throws: CoreError.OSStatusFailure if fails.
    public func key() throws -> Data {
        guard let tag = identifier.data(using: String.Encoding.utf8) else {
            throw CoreError.Failed("Failed to convert the SecureKey identifier to data")
        }
        let query = NSDictionary(objects:[kSec.classKey, tag, length, true],
                                 forKeys: [kSec.class, kSec.attrApplicationTag, kSec.attrKeySizeInBits, kSec.returnData])
        var dataRef : CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
        switch status {
        case errSecSuccess:
            let data = dataRef as! Data
            return data
        case -25308: // errKCInteractionNotAllowed
            // If reading fails because app is not allowed (device locked)
            // Fix cannot be applied because we cannot read the current keychain item.
            throw CoreError.OSStatusFailure(status, "Failed to fetch Keychain because the device is locked (OSStatus: \(status)).")
        default:
            // If no pre-existing key from this application

            guard let keyData = Data(randomOfLength: UInt(length)) else {
                throw CoreError.Failed("Failed to generate random key")
            }
            
            let query = NSDictionary(objects:[kSec.classKey, tag, length, kSec.attrAccessibleAlways, keyData],
                                     forKeys:[kSec.class, kSec.attrApplicationTag, kSec.attrKeySizeInBits, kSec.attrAccessible, kSec.valueData])
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw CoreError.OSStatusFailure(status, "Failed to insert key data with OSStatus: \(status)")
            }
            return keyData
        }
    }
}

//public extension Data {
//    init?(randomOfLength length: Int) {
//        var bytes = [UInt8](repeating: 0, count: length)
//        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
//        if status == errSecSuccess {
//            self.init(bytes)
//        } else {
//            return nil
//        }
//    }
//}
