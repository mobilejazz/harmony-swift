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

public class UserDefaultsDataSource<T> : DataSource<T> {

    private let userDefaults : UserDefaults
    private let prefix : String
    
    public init(_ userDefaults: UserDefaults = UserDefaults.standard, prefix: String = "") {
        self.userDefaults = userDefaults
        self.prefix = prefix
    }
    
    private func addPrefixTo(_ key: String?) -> String? {
        guard let key = key else {
            return nil
        }
        switch prefix.count {
        case 0:
            return key
        default:
            return prefix + "." + key
        }
    }
    
    public override func get(_ query: Query) -> Future<T?> {
        guard let key = addPrefixTo(query.key()) else {
            return super.get(query)
        }
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
        return Future(value)
    }
    
    public override func getAll(_ query: Query) -> Future<[T]> {
        guard let key = addPrefixTo(query.key()) else {
            return super.getAll(query)
        }
        if let array = userDefaults.array(forKey: key) as? [T] {
            return Future(array)
        }
        return Future([])
    }
    
    @discardableResult
    public override func put(_ value: T, in query: Query) -> Future<T> {
        guard let key = addPrefixTo(query.key()) else {
            return super.put(value, in: query)
        }
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
        return Future(value)
    }
    
    @discardableResult
    public override func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        guard let key = addPrefixTo(query.key()) else {
            return super.putAll(array, in: query)
        }
        userDefaults.set(array, forKey: key)
        userDefaults.synchronize()
        return Future(array)
    }
    
    @discardableResult
    public override func delete(_ value: T?, in query: Query) -> Future<Bool> {
        guard let key = addPrefixTo(query.key()) else {
            return super.delete(value, in: query)
        }
        userDefaults.removeObject(forKey: key)
        return Future(userDefaults.synchronize())
    }
    
    @discardableResult
    public override func deleteAll(_ array: [T], in query: Query) -> Future<Bool> {
        guard let key = addPrefixTo(query.key()) else {
            return super.deleteAll(array, in: query)
        }
        userDefaults.removeObject(forKey: key)
        return Future(userDefaults.synchronize())
    }
}
