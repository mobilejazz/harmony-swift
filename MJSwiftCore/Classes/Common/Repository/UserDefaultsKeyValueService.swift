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
// Provides a user defaults service for a key value interface
//
public class UserDefaultsKeyValueService <T> : KeyValueInterface <T> {
    private let userDefaults : UserDefaults
    public init(_ userDefaults : UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public override func get(_ key: String) -> T? {
        let value : T? = {
            switch T.self {
            case is Int.Type:
                return userDefaults.integer(forKey: key) as? T
            case is [Int].Type:
                return userDefaults.array(forKey: key) as? T
            case is Double.Type:
                return userDefaults.double(forKey: key) as? T
            case is [Double].Type:
                return userDefaults.array(forKey: key) as? T
            case is Bool.Type:
                return userDefaults.bool(forKey: key) as? T
            case is [Bool].Type:
                return userDefaults.array(forKey: key) as? T
            case is Float.Type:
                return userDefaults.float(forKey: key) as? T
            case is [Float].Type:
                return userDefaults.array(forKey: key) as? T
            case is Data.Type:
                return userDefaults.data(forKey: key) as? T
            case is [Data].Type:
                return userDefaults.array(forKey: key) as? T
            case is String.Type:
                return userDefaults.string(forKey: key) as? T
            case is [String].Type:
                return userDefaults.stringArray(forKey: key) as? T
            case is URL.Type:
                return userDefaults.url(forKey: key) as? T
            case is [URL].Type:
                return userDefaults.array(forKey: key) as? T
            case is Date.Type:
                return userDefaults.object(forKey: key) as? T
            case is [Date].Type:
                return userDefaults.array(forKey: key) as? T
            case is [Any].Type:
                return userDefaults.array(forKey: key) as? T
            case is [String:Any].Type:
                return userDefaults.dictionary(forKey: key) as? T
            default:
                return userDefaults.object(forKey: key) as? T
            }
        }()
        return value
    }
    
    public override func getAll(_ key: String) -> [T]? {
        return userDefaults.array(forKey: key) as? [T]
    }
    
    public override func set(_ value: T, forKey key: String) -> Bool {
        userDefaults.set(value, forKey: key)
        return userDefaults.synchronize()
    }
    
    public override func setAll(_ values: [T], forKey key: String) -> Bool {
        userDefaults.set(values, forKey: key)
        return userDefaults.synchronize()
    }
    
    public override func delete(_ key: String) -> Bool {
        userDefaults.removeObject(forKey: key)
        return userDefaults.synchronize()
    }
}
