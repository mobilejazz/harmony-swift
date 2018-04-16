
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

// Arguments for the keychain queries
private let kSecClassGenericPasswordStr = NSString(format: kSecClassGenericPassword)
private let kSecClassStr                = NSString(format: kSecClass)
private let kSecAttrServiceStr          = NSString(format: kSecAttrService)
private let kSecAttrAccountStr          = NSString(format: kSecAttrAccount)
private let kSecReturnAttributesStr     = NSString(format: kSecReturnAttributes)
private let kSecValueDataStr            = NSString(format: kSecValueData)
private let kSecMatchLimitStr           = NSString(format: kSecMatchLimit)
private let kSecMatchLimitOneStr        = NSString(format: kSecMatchLimitOne)
private let kSecReturnDataStr           = NSString(format: kSecReturnData)

/// A user-friendly interface to store Data inside the keychain.
public class Keychain {
    
    /// The Keychain's service name.
    public let service : String
    
    /// Main initializer
    /// The initializer needs a service name. Each service will identify an independent keychain memory zone.
    ///
    /// - Parameter service: The keychain service name. Default service is "com.default.service"
    public init(_ service: String = "com.default.service") {
        self.service = service
    }
    
    /// A keychain operation result.
    ///
    /// - success: A success result
    /// - failed: A failre result, including the status code.
    public enum Result : Error {
        case success
        case failed(OSStatus)
    }
    
    /// Fetches the Data stored in the keychain for the given key.
    ///
    /// - Parameter key: The key.
    /// - Returns: The stored Data or nil.
    public func get(_ key: String) -> Data? {
        let query = NSDictionary(objects:[kSecClassGenericPasswordStr, service, key, kCFBooleanTrue, kSecMatchLimitOneStr],
                                 forKeys: [kSecClassStr, kSecAttrServiceStr, kSecAttrAccountStr, kSecReturnDataStr, kSecMatchLimitStr])
        
        var dataRef : CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
        
        if status == errSecSuccess {
            let data = dataRef as? Data
            return data
        }
        return nil
    }
    
    /// Sets the given Data for the given key inside the keychain.
    ///
    /// - Parameters:
    ///   - data: The data to store.
    ///   - key: The key of the data.
    /// - Returns: The operation result.
    @discardableResult
    public func set(_ data: Data, forKey key: String) -> Result {
        let query = NSMutableDictionary(objects:[kSecClassGenericPasswordStr, service, key, kCFBooleanTrue],
                                        forKeys:[kSecClassStr, kSecAttrServiceStr, kSecAttrAccountStr, kSecReturnAttributesStr])
        // Delete first and old entry
        let deleteStatus = SecItemDelete(query as CFDictionary)
        if deleteStatus != errSecSuccess {
            // Nothing to do
        }
        
        // Setting the data
        query.setObject(data, forKey: kSecValueDataStr)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            return .failed(status)
        } else {
            return .success
        }
    }
    
    /// Deletes the Data associated to the given key.
    ///
    /// - Parameter key: The key.
    /// - Returns: The operation result.
    @discardableResult
    public func delete(_ key: String) -> Result {
        let query = NSMutableDictionary(objects:[kSecClassGenericPasswordStr, service, key, kCFBooleanTrue],
                                        forKeys:[kSecClassStr, kSecAttrServiceStr, kSecAttrAccountStr, kSecReturnAttributesStr])
        // Delete first and old entry
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            return .failed(status)
        } else {
            return .success
        }
    }
}

public extension Keychain {
    
    /// Custom getter for Decodable conforming types.
    ///
    /// - Parameter key: The key.
    /// - Returns: The type stored in the keychain or nil.
    public func get<T>(_ key: String) ->T? where T:Decodable {
        guard let data : Data = get(key) else {
            return nil
        }
        do {
            let value = try PropertyListDecoder().decode(T.self, from: data)
            return value
        } catch {
            return nil
        }
    }
    
    /// Custom setter for Encodable conforming types.
    ///
    /// - Parameters:
    ///   - value: The Encodable conforming value.
    ///   - key: The key.
    /// - Returns: The operation result.
    public func set<T>(_ value: T, forKey key: String) -> Result where T:Encodable {
        do {
            let data = try PropertyListEncoder().encode(value)
            return set(data, forKey: key)
        } catch {
            return Keychain.Result.failed(0)
        }
    }
    
    /// Custom getter for NSCoding conforming types.
    ///
    /// - Parameter key: The key.
    /// - Returns: The NSCoding conforming type stored in the keychain or nil.
    public func get<T>(_ key: String) -> T? where T: NSCoding {
        if let data : Data = get(key) {
            if let value = NSKeyedUnarchiver.unarchiveObject(with: data) {
                return (value as! T)
            } else {
                return nil
            }
        }
        return nil
    }
    
    /// Custom setter for NSCoding conforming types.
    ///
    /// - Parameters:
    ///   - value: The NSCoding conforming value.
    ///   - key: The key.
    /// - Returns: The operation result.
    @discardableResult
    public func set<T>(_ value: T, forKey key: String) -> Result where T: NSCoding {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return set(data, forKey: key)
    }
}
