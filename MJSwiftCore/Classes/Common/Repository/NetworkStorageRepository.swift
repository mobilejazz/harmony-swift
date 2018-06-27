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

/// - network: Data stream will only use network
public class NetworkOperation : Operation { public init () { } }
/// - networkSync: Data stream will use network and sync with storage if needed
public class NetworkSyncOperation : Operation { public init () { } }
/// - storage: Data stream will only use storage
public class StorageOperation : Operation { public init () { } }
/// - storageSync: Data stream will use storage and sync with network if needed
public class StorageSyncOperation : Operation { public init () { } }

///
/// Generic DataProvider implementation for network an storage operations
///
public class NetworkStorageRepository<N: DataSource,S: DataSource,T> : Repository where N.T == T, S.T == T {
    
    private let network: N
    private let storage: S
    
    public init(network: N, storage: S) {
        self.network = network
        self.storage = storage
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        return { () -> Future<T> in
            switch operation {
            case is NetworkOperation:
                return network.get(query)
            case is StorageOperation:
                return storage.get(query)
            case is NetworkSyncOperation:
                return network.get(query).flatMap { entity in
                    return self.storage.put(entity, in: query)
                }
            case is StorageSyncOperation:
                return storage.get(query).recover { error in
                    switch error {
                    case is CoreError.NotValid, is CoreError.NotFound:
                        return self.get(query, operation: NetworkSyncOperation())
                    default:
                        return Future(error)
                    }
                }
            default:
                operation.fatalError(.get, self)
            }
            }()
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        return { () -> Future<[T]> in
            switch operation {
            case is NetworkOperation:
                return network.getAll(query)
            case is StorageOperation:
                return storage.getAll(query)
            case is NetworkSyncOperation:
                return network.getAll(query).flatMap { entities in
                    return self.storage.putAll(entities, in: query)
                }
            case is StorageSyncOperation:
                return storage.getAll(query).recover { error in
                    switch error {
                    case is CoreError.NotValid, is CoreError.NotFound:
                        return self.getAll(query, operation: NetworkSyncOperation())
                    default:
                        return Future(error)
                    }
                }
            default:
                operation.fatalError(.getAll, self)
            }
            }()
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return { () -> Future<T> in
            switch operation {
            case is NetworkOperation:
                return network.put(value, in: query)
            case is StorageOperation:
                return storage.put(value, in: query)
            case is NetworkSyncOperation:
                return network.put(value, in: query).flatMap { value in
                    return self.storage.put(value, in: query)
                }
            case is StorageSyncOperation:
                return storage.put(value, in: query).flatMap { value in
                    return self.network.put(value, in: query)
                }
            default:
                operation.fatalError(.put, self)
            }
            }()
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return { () -> Future<[T]> in
            switch operation {
            case is NetworkOperation:
                return network.putAll(array, in: query)
            case is StorageOperation:
                return storage.putAll(array, in: query)
            case is NetworkSyncOperation:
                return network.putAll(array, in: query).flatMap { array in
                    return self.storage.putAll(array, in: query)
                }
            case is StorageSyncOperation:
                return storage.putAll(array, in: query).flatMap { array in
                    return self.network.putAll(array, in: query)
                }
            default:
                operation.fatalError(.putAll, self)
            }
            }()
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return { () -> Future<Void> in
            switch operation {
            case is NetworkOperation:
                return network.delete(query)
            case is StorageOperation:
                return storage.delete(query)
            case is NetworkSyncOperation:
                return network.delete(query).flatMap {
                    return self.storage.delete(query)
                }
            case is StorageSyncOperation:
                return storage.delete(query).flatMap {
                    return self.network.delete(query)
                }
            default:
                operation.fatalError(.delete, self)
            }
            }()
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return { () -> Future<Void> in
            switch operation {
            case is NetworkOperation:
                return network.deleteAll(query)
            case is StorageOperation:
                return storage.deleteAll(query)
            case is NetworkSyncOperation:
                return network.deleteAll(query).flatMap {
                    return self.storage.deleteAll(query)
                }
            case is StorageSyncOperation:
                return storage.deleteAll(query).flatMap {
                    return self.network.deleteAll(query)
                }
            default:
                operation.fatalError(.deleteAll, self)
            }
            }()
    }
}
