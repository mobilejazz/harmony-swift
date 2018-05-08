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

extension Operation {
    /// - network: Data stream will only use network
    public static let network = Operation(rawValue: "network")
    /// - networkSync: Data stream will use network and sync with storage if needed
    public static let networkSync = Operation(rawValue: "networkSync")
    /// - storage: Data stream will only use storage
    public static let storage = Operation(rawValue: "storage")
    /// - storageSync: Data stream will use storage and sync with network if needed
    public static let storageSync = Operation(rawValue: "storageSync")
}

///
/// Generic DataProvider implementation for network an storage operations
///
public class NetworkStorageRepository<T> : Repository<T>  {
    
    private let network: DataSource<T>
    private let storage: DataSource<T>
    
    public init(network: DataSource<T>, storage: DataSource<T>) {
        self.network = network
        self.storage = storage
    }
    
    public override func get(_ query: Query, operation: Operation = .storageSync) -> Future<T?> {
        return getAll(query, operation: operation).map { array in
            return array.first
        }
    }
    
    public override func getAll(_ query: Query, operation: Operation = .storageSync) -> Future<[T]> {
        return { () -> Future<[T]> in
            switch operation {
            case .network:
                return network.getAll(query)
            case .storage:
                return storage.getAll(query)
            case .networkSync:
                return network.getAll(query).filter { entities in
                    self.storage.putAll(entities, in: query)
                }
            case .storageSync:
                return storage.getAll(query).recover { error in
                    switch error {
                    case ValidationError.notValid:
                        return self.network.getAll(query).filter { entities in
                            self.storage.putAll(entities, in: query)
                        }
                    default:
                        return Future(error)
                    }
                }
            default:
                return super.getAll(query, operation: operation)
            }
            }()
    }
    
    @discardableResult
    public override func put(_ value: T?, in query: Query, operation: Operation = .networkSync) -> Future<T> {
        return { () -> Future<T> in
            switch operation {
            case .network:
                return network.put(value, in: query)
            case .storage:
                return storage.put(value, in: query)
            case .networkSync:
                return network.put(value, in: query).flatMap { value in
                    return self.storage.put(value, in: query)
                }
            case .storageSync:
                return storage.put(value, in: query).flatMap { value in
                    return self.network.put(value, in: query)
                }
            default:
                return super.put(value, in: query, operation: operation)
            }
            }()
    }
    
    @discardableResult
    public override func putAll(_ array: [T], in query: Query, operation: Operation = .networkSync) -> Future<[T]> {
        return { () -> Future<[T]> in
            switch operation {
            case .network:
                return network.putAll(array, in: query)
            case .storage:
                return storage.putAll(array, in: query)
            case .networkSync:
                return network.putAll(array, in: query).flatMap { array in
                    return self.storage.putAll(array, in: query)
                }
            case .storageSync:
                return storage.putAll(array, in: query).flatMap { array in
                    return self.network.putAll(array, in: query)
                }
            default:
                return super.putAll(array, in: query, operation: operation)
            }
            }()
    }
    
    @discardableResult
    public override func delete(_ value: T?, in query: Query, operation: Operation = .networkSync) -> Future<Bool> {
        return { () -> Future<Bool> in
            switch operation {
            case .network:
                return network.delete(value, in: query)
            case .storage:
                return storage.delete(value, in: query)
            case .networkSync:
                return network.delete(value, in: query).flatMap { success in
                    if success {
                        return self.storage.delete(value, in: query)
                    } else {
                        return false.toFuture()
                    }
                }
            case .storageSync:
                return storage.delete(value, in: query).flatMap { success in
                    if success {
                        return self.network.delete(value, in: query)
                    } else {
                        return false.toFuture()
                    }
                }
            default:
                return super.delete(value, in: query, operation: operation)
            }
            }()
    }
    
    @discardableResult
    public override func deleteAll(_ array: [T], in query: Query, operation: Operation = .networkSync) -> Future<Bool> {
        return { () -> Future<Bool> in
            switch operation {
            case .network:
                return network.deleteAll(array, in: query)
            case .storage:
                return storage.deleteAll(array, in: query)
            case .networkSync:
                return network.deleteAll(array, in: query).flatMap { success in
                    if success {
                        return self.storage.deleteAll(array, in: query)
                    } else {
                        return false.toFuture()
                    }
                }
            case .storageSync:
                return storage.deleteAll(array, in: query).flatMap { success in
                    if success {
                        return self.network.deleteAll(array, in: query)
                    } else {
                        return false.toFuture()
                    }
                }
            default:
                return super.deleteAll(array, in: query, operation: operation)
            }
            }()
    }
}
