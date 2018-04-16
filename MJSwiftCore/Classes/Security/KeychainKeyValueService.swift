//
// Copyright 2018 Mobile Jazz SL
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

//
// Provides a keychain service for a key value interface
//
public class KeychainKeyValueService <T> : KeyValueInterface <T> where T:Codable {
    private let keychain : Keychain
    public init(_ keychain : Keychain) {
        self.keychain = keychain
    }
    
    public override func get(_ key: String) -> T? {
        let value : T? = keychain.get(key)
        return value
    }
    
    public override func getAll(_ key: String) -> [T]? {
        let array : NSArray? = keychain.get(key)
        return array as? [T]
    }
    
    @discardableResult
    public override func set(_ value: T, forKey key: String) -> Bool {
        switch keychain.set(value, forKey: key) {
        case .success:
            return true
        case .failed(_):
            return false
        }
    }
    
    @discardableResult
    public override func setAll(_ array: [T], forKey key: String) -> Bool {
        let nsarray = array as NSArray
        switch keychain.set(nsarray, forKey: key) {
        case .success:
            return true
        case .failed(_):
            return false
        }
    }
    
    @discardableResult
    public override func delete(_ key: String) -> Bool {
        switch keychain.delete(key) {
        case .success:
            return true
        case .failed(_):
            return false
        }
    }
}
