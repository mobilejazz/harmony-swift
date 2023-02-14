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

public enum DeviceStorageType {
    case regular
    case prefix(String)
    case rootKey(String)
    
    fileprivate func key(_ key: String) -> String {
        switch self {
        case .prefix(let prefix):
            switch prefix.count {
            case 0:
                return key
            default:
                return prefix + "." + key
            }
        default:
            return key
        }
    }
}

public class DeviceStorageDataSource <T> : GetDataSource, PutDataSource, DeleteDataSource  {
    
    private let userDefaults : UserDefaults
    private let storageType : DeviceStorageType
    
    public init(_ userDefaults: UserDefaults = UserDefaults.standard, storageType: DeviceStorageType = .regular) {
        self.userDefaults = userDefaults
        self.storageType = storageType
    }
    
    public init(_ userDefaults: UserDefaults = UserDefaults.standard, prefix: String) {
        self.userDefaults = userDefaults
        self.storageType = .prefix(prefix)
    }
    
    private func getRootKey() -> String? {
        switch storageType {
        case .rootKey(let rootKey):
            return "\(rootKey)<\(String(describing:T.self))>"
        default:
            return nil
        }
    }
    
    public func get(_ query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            let key = storageType.key(query.key)
            guard let value : T = {
                
                if let rootKey = getRootKey() {
                    return userDefaults.dictionary(forKey: rootKey)?[key] as? T
                }
                
                return userDefaults.object(forKey: key) as? T
                
                }() else {
                    return Future(CoreError.NotFound())
            }
            
            return Future(value)
        default:
            return Future(CoreError.QueryNotSupported())
        }
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        switch query {
        case let query as IdsQuery<String>:
            return Future.batch(query.ids.map { get(IdQuery($0)) })
        case is AllObjectsQuery:
            switch storageType {
            case .regular:
                return Future(CoreError.QueryNotSupported("AllObjectsQuery is not supported with storagType regular."))
            case .rootKey(_):
                let rootKey = getRootKey()! // Will always be present in this case
                    
                guard let dict = userDefaults.dictionary(forKey: rootKey) else {
                    return Future(CoreError.NotFound())
                }
                // Dict can be composed of components of type T or [T].
                // Let's add it all together in an array.
                var array = [T]()
                dict.forEach { (key, value) in
                    if let value = value as? T {
                        array.append(value)
                    } else if let values = value as? [T] {
                        array.append(contentsOf: values)
                    } else {
                        // Ignore the value as its type doesn't match
                    }
                }
                return Future(array)
            case .prefix(let prefix):
                var array = [T]()
                userDefaults.dictionaryRepresentation().forEach { (key, value) in
                    // Let's search for keys with the given prefix
                    guard key.hasPrefix(prefix) else { return }
                    
                    // value now can be composed of type T or [T] or any other type.
                    // Let's add it all together in an array if base type is T.
                    if let value = value as? T {
                        array.append(value)
                    } else if let values = value as? [T] {
                        array.append(contentsOf: values)
                    } else {
                        // Ignore the value as its type doesn't match
                    }
                }
                return Future(array)
            }
        case let query as KeyQuery:
            let key = storageType.key(query.key)
            if let rootKey = getRootKey() {
                guard let array = userDefaults.dictionary(forKey: rootKey)?[key] as? [T] else {
                    return Future(CoreError.NotFound())
                }
                return Future(array)
            } else {
                guard let array = userDefaults.array(forKey: key) as? [T] else {
                    return Future(CoreError.NotFound())
                }
                return Future(array)
            }
        default:
            return Future(CoreError.QueryNotSupported())
        }
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            guard let value = value else {
                return Future(CoreError.IllegalArgument("Value cannot be nil"))
            }
            let key = storageType.key(query.key)
            if let rootKey = getRootKey() {
                var root = userDefaults.dictionary(forKey: rootKey) ?? [String : Any]()
                root[key] = value
                userDefaults.set(root, forKey: rootKey)
            } else {
                userDefaults.set(value, forKey: key)
            }
            userDefaults.synchronize()
            return Future(value)
        default:
            return Future(CoreError.QueryNotSupported())
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        switch query {
        case let query as IdsQuery<String>:
            guard array.count == query.ids.count else {
                return Future(CoreError.IllegalArgument("Array lenght must be equal to query.ids length"))
            }
            return Future.batch(array.enumerated().map { put($0.element, in: IdQuery(query.ids[$0.offset])) })
        case let query as KeyQuery:
            let key = storageType.key(query.key)
            if let rootKey = getRootKey() {
                var root = userDefaults.dictionary(forKey: rootKey) ?? [String : Any]()
                root[key] = array
                userDefaults.set(root, forKey: rootKey)
            } else {
                userDefaults.set(array, forKey: key)
            }
            userDefaults.synchronize()
            return Future(array)
        default:
            return Future(CoreError.QueryNotSupported())
        }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as IdsQuery<String>:
            return Future.batch(query.ids.map { delete(IdQuery($0)) }).map { _ in Void() }
        case is AllObjectsQuery:
            switch storageType {
            case .regular:
                return Future(CoreError.QueryNotSupported("AllObjectsQuery is not supported with storagType regular."))
            case .rootKey(_):
                let rootKey = getRootKey()! // Will always be present in this case
                userDefaults.removeObject(forKey: rootKey)
                userDefaults.synchronize()
                return Future(Void())
            case .prefix(let prefix):
                userDefaults.dictionaryRepresentation().forEach { (key, value) in
                    // Let's search for keys with the given prefix
                    guard key.hasPrefix(prefix) else { return }
                    
                    // value now can be composed of type T or [T] or any other type.
                    // Let's delete the object if its type match
                    if let _ = value as? T {
                        userDefaults.removeObject(forKey: key)
                    } else if let _ = value as? [T] {
                        userDefaults.removeObject(forKey: key)
                    } else {
                        // Ignore the value as its type doesn't match
                    }
                }
                return Future(Void())
            }
        case let query as KeyQuery:
            let key = storageType.key(query.key)
            if let rootKey = getRootKey() {
                var root = userDefaults.dictionary(forKey: rootKey) ?? [String : Any]()
                root.removeValue(forKey: key)
                userDefaults.set(root, forKey: rootKey)
            } else {
                userDefaults.removeObject(forKey: key)
            }
            userDefaults.synchronize()
            return Future(Void())
        default:
            return Future(CoreError.QueryNotSupported())
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        delete(query)
    }
}

