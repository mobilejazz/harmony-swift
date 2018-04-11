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

///
/// Key-value based repository to store data in UserDefaults.
/// The repository only works with QueryById and KeyValueQuery types.
///
public class UserDefaultsRepository <T> : Repository<T> {
    
    private let userDefaults : UserDefaults
    private let keyPrefix : String

    public init(_ userDefaults : UserDefaults, keyPrefix: String = "") {
        self.userDefaults = userDefaults
        if keyPrefix.count > 0 {
            self.keyPrefix = keyPrefix + "."
        } else {
            self.keyPrefix = ""
        }
    }
    
    private func key(_ string: String) -> String {
        return keyPrefix + string
    }
    
    public override func get(_ query: Query, operation: Operation) -> Future<T?> {
        switch query.self {
        case is QueryById:
            let key = self.key((query as! QueryById).id)
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
        default:
            return super.get(query, operation: operation)
        }
    }
    
    public override func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        switch query.self {
        case is QueryById:
            let key = self.key((query as! QueryById).id)
            let array = userDefaults.array(forKey: key) as? [T]
            if let array = array {
                return Future(array)
            } else {
                return Future([])
            }
        case is AllObjectsQuery:
            let key = self.key(String(describing:T.self) + ".allObjects")
            let array = userDefaults.array(forKey: key) as? [T]
            if let array = array {
                return Future(array)
            } else {
                return Future([])
            }
        default:
            return super.getAll(query, operation: operation)
        }
    }
    
    public override func put(_ value: T, in query: Query, operation: Operation) -> Future<T> {
        switch query.self {
        case is QueryById:
            userDefaults.set(value, forKey: key((query as! QueryById).id))
            userDefaults.synchronize()
            return Future(value)
        default:
            return super.put(value, in: query, operation: operation)
        }
    }
    
    public override func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        switch query.self {
        case is QueryById:
            userDefaults.set(array, forKey: self.key((query as! QueryById).id))
            userDefaults.synchronize()
            return Future(array)
        case is AllObjectsQuery:
            userDefaults.set(array, forKey: self.key(String(describing:T.self) + ".allObjects"))
            userDefaults.synchronize()
            return Future(array)
        default:
            return super.putAll(array, in: query, operation: operation)
        }
    }
    
    public override func delete(_ value: T?, in query: Query, operation: Operation) -> Future<Bool> {
        switch query.self {
        case is QueryById:
            let key = self.key((query as! QueryById).id)
            userDefaults.removeObject(forKey: key)
            return Future(userDefaults.synchronize())
        case is AllObjectsQuery:
            userDefaults.removeObject(forKey: self.key(String(describing:T.self) + ".allObjects"))
            return Future(userDefaults.synchronize())
        default:
            return super.delete(value, in: query, operation: operation)
        }
    }
    
    public override func deleteAll(_ array: [T], in query: Query, operation: Operation) -> Future<Bool> {
        switch query.self {
        case is QueryById:
            let key = self.key((query as! QueryById).id)
            userDefaults.removeObject(forKey: key)
            return Future(userDefaults.synchronize())
        default:
            return super.deleteAll(array, in: query, operation: operation)
        }
    }
}

