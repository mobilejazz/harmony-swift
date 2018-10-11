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

public class DeviceStorageDataSource <T> : GetDataSource, PutDataSource, DeleteDataSource  {

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
    
    public func get(_ query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            let key = query.key
            guard let value : T = {
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
                }() else {
                    return Future(CoreError.NotFound())
            }
            return Future(value)
        default:
            query.fatalError(.get, self)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        switch query {
        case let query as KeyQuery:
            guard let array = userDefaults.array(forKey: query.key) as? [T] else {
                return Future(CoreError.NotFound())
            }
            return Future(array)
        default:
            query.fatalError(.getAll, self)
        }
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            guard let value = value else {
                return Future(CoreError.IllegalArgument("Value cannot be nil"))
            }
            userDefaults.set(value, forKey: query.key)
            userDefaults.synchronize()
            return Future(value)
        default:
            query.fatalError(.put, self)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        switch query {
        case let query as KeyQuery:
            userDefaults.set(array, forKey: query.key)
            userDefaults.synchronize()
            return Future(array)
        default:
            query.fatalError(.putAll, self)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            userDefaults.removeObject(forKey: query.key)
            userDefaults.synchronize()
            return Future(Void())
        default:
            query.fatalError(.delete, self)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            userDefaults.removeObject(forKey: query.key)
            userDefaults.synchronize()
            return Future(Void())
        default:
            query.fatalError(.deleteAll, self)
        }
    }
}
