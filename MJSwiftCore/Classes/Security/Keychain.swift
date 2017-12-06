
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

public class Keychain {
    
    public let service : String
    
    public init(_ service: String = "com.default.service") {
        self.service = service
    }
    
    public enum Result : Error {
        case success
        case failed(OSStatus)
    }
    
    // Arguments for the keychain queries
    private let kSecClassGenericPasswordStr = NSString(format: kSecClassGenericPassword)
    private let kSecClassStr = NSString(format: kSecClass)
    private let kSecAttrServiceStr = NSString(format: kSecAttrService)
    private let kSecAttrAccountStr = NSString(format: kSecAttrAccount)
    private let kSecReturnAttributesStr = NSString(format: kSecReturnAttributes)
    private let kSecValueDataStr = NSString(format: kSecValueData)
    private let kSecMatchLimitStr = NSString(format: kSecMatchLimit)
    private let kSecMatchLimitOneStr = NSString(format: kSecMatchLimitOne)
    private let kSecReturnDataStr = NSString(format: kSecReturnData)
    
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
    public func get<T>(_ key: String) -> T? where T: DataConvertible {
        guard let data : Data = get(key) else {
            return nil
        }
        return T(data:data)
    }

    @discardableResult
    public func set<T>(_ value: T, forKey key: String) -> Result where T: DataConvertible {
        return set(value.data, forKey: key)
    }
    
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

    @discardableResult
    public func set<T>(_ value: T, forKey key: String) -> Result where T: NSCoding {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        return set(data, forKey: key)
    }
}
