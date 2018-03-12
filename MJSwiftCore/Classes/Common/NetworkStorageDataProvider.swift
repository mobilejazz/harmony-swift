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
public class NetworkStorageDataProvider <T> : DataProvider <T>  {
    
    private let network: Repository<T>
    private let storage: Repository<T>
    
    public init(network: Repository<T>,
                storage: Repository<T>) {
        self.network = network
        self.storage = storage
    }
    
    override public func get(_ query: Query, operation: Operation) -> Future<[T]> {
        return { () -> Future<[T]> in
            switch operation {
            case .none:
                return Future([])
            case .network:
                return network.get(query)
            case .storage:
                return storage.get(query)
            case .networkSync:
                return network.get(query).filter { entities in
                    self.storage.put(ArrayQuery(entities))
                }
            case .storageSync:
                return storage.get(query).recover { error in
                    switch error {
                    case ValidationError.notValid:
                        return self.network.get(query).filter { entities in
                            self.storage.put(ArrayQuery(entities))
                        }
                    default:
                        return Future(error)
                    }
                }
            default:
                return super.get(query, operation: operation)
            }
            }()
    }
    
    @discardableResult
    override public func put(_ query: Query, operation: Operation) -> Future<[T]> {
        return { () -> Future<[T]> in
            switch operation {
            case .none:
                return Future([])
            case .network:
                return network.put(query)
            case .storage:
                return storage.put(query)
            case .networkSync:
                return network.put(query).flatMap { array in
                    return self.storage.put(query)
                }
            case .storageSync:
                return storage.put(query).flatMap { array in
                    return self.network.put(query)
                }
            default:
                return super.put(query, operation: operation)
            }
            }()
    }
    
    @discardableResult
    override public func delete(_ query: Query, operation: Operation) -> Future<Bool> {
        return { () -> Future<Bool> in
            switch operation {
            case .none:
                return Future(false)
            case .network:
                return network.delete(query)
            case .storage:
                return storage.delete(query)
            case .networkSync:
                return network.delete(query).flatMap { success in
                    if success {
                        return self.storage.delete(query)
                    } else {
                        return false.toFuture()
                    }
                }
            case .storageSync:
                return storage.delete(query).flatMap { success in
                    if success {
                        return self.network.delete(query)
                    } else {
                        return false.toFuture()
                    }
                }
            default:
                return super.delete(query, operation: operation)
            }
            }()
    }
}
