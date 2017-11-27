//
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

/// Data provider operation type
///
/// - network: Data stream will only use network
/// - networkSync: Data stream will use network and sync with storage if needed
/// - storage: Data stream will only use storage
/// - storageSync: Data stream will use storage and sync with network if needed
public enum Operation {
    case network
    case networkSync
    case storage
    case storageSync
}

extension Operation: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch(self) {
        case .network:
            return "network"
        case .networkSync:
            return "networkSync"
        case .storage:
            return "storage"
        case .storageSync:
            return "storageSync"
        }
    }
    
    public var debugDescription: String {
        return self.description
    }
}

///
/// Abstract DataProvider
///
open class DataProvider <T> {
    
    /// Main get method
    ///
    /// - Parameters:
    ///   - query: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type list of T
    open func get(_ query: Query, operation: Operation) -> Future<[T]> {
        fatalError("Undefined behavior on method get on class \(String(describing: type(of:self))) for operation \(operation) and query \(String(describing: type(of:query)))")
    }
    
    /// Main put method
    ///
    /// - Parameters:
    ///   - values: List of values of type T to be put
    ///   - operation: The operation type
    /// - Returns: A future of type list of T
    @discardableResult
    open func put(_ values: [T], operation: Operation) -> Future<[T]> {
        fatalError("Undefined behavior on method put on class \(String(describing: type(of:self))) for operation \(operation)")
    }
    
    /// Main delete method
    ///
    /// - Parameters:
    ///   - query: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type list of Bool. If the operation succeeds, the future will be resovled with true.
    @discardableResult
    open func delete(_ query: Query, operation: Operation) -> Future<Bool> {
        fatalError("Undefined behavior on method delete on class \(String(describing: type(of:self))) for operation \(operation) and query \(String(describing: type(of:query)))")
    }
}

extension DataProvider {
    
    /// Custom put for a single value
    ///
    /// - Parameters:
    ///   - value: The value of type T to be put
    ///   - operation: The operation type
    /// - Returns: A future of type T
    @discardableResult
    open func put(_ value: T, operation: Operation) -> Future<T> {
        return put([value], operation: operation).map({ (array) -> T in
            return array.first!
        })
    }
}


///
/// Generic DataProvider implementation
///
public class GenericDataProvider <O, E> : DataProvider <O>  {
    
    private let network: Repository<E>
    private let storage: Repository<E>
    private let toEntityMapper: Mapper<O, E>
    private let toObjectMapper: Mapper<E, O>
    private let storageValidation: VastraService
    
    public init(network: Repository<E>,
                storage: Repository<E>,
                storageValidation: VastraService,
                toEntityMapper: Mapper<O, E>,
                toObjectMapper: Mapper<E, O>) {
        self.network = network
        self.storage = storage
        self.storageValidation = storageValidation
        self.toEntityMapper = toEntityMapper
        self.toObjectMapper = toObjectMapper
    }
    
    override public func get(_ query: Query, operation: Operation) -> Future<[O]> {
        return { () -> Future<[E]> in
            switch operation {
            case .network:
                return self.network.get(query)
            case .storage:
                return self.storage.get(query)
            case .networkSync:
                return self.network.get(query).andThen(success: { entities in
                    if let entities = entities {
                        self.storage.put(entities)
                    }
                })
            case .storageSync:
                return storage.get(query).flatMap { values -> Future<[E]> in
                    if !self.storageValidation.isObjectValid(values) {
                        return self.network.get(query).andThen(success: { entities in
                            if let entities = entities {
                                self.storage.put(entities)
                            }
                        })
                    } else {
                        return Future(values)
                    }
                }
            }
            }().map({ entities -> [O] in
                return entities.map { value -> O in
                    return self.toObjectMapper.transform(value)
                }
            })
    }
    
    @discardableResult
    override public func put(_ values: [O], operation: Operation) -> Future<[O]> {
        let array = values.map { (object) -> E in
            return toEntityMapper.transform(object)
        }
        
        return { () -> Future<[E]> in
            switch operation {
            case .network:
                return self.network.put(array)
            case .storage:
                return self.storage.put(array)
            case .networkSync:
                return self.network.put(array).andThen(success: { (entities) in
                    if let entities = entities {
                        self.storage.put(entities)
                    }
                })
            case .storageSync:
                return self.storage.put(array).andThen(success: { (entities) in
                    if let entities = entities {
                        self.network.put(entities)
                    }
                })
            }
            }().map({ entities -> [O] in
                return entities.map { value -> O in
                    return self.toObjectMapper.transform(value)
                }
            })
    }
    
    @discardableResult
    override public func delete(_ query: Query, operation: Operation) -> Future<Bool> {
        return { () -> Future<Bool> in
            switch operation {
            case .network:
                return self.network.delete(query)
            case .storage:
                return self.storage.delete(query)
            case .networkSync:
                return self.network.delete(query).andThen(success: { (success) in
                    if let success = success {
                        if success {
                            self.storage.delete(query)
                        }
                    }
                })
            case .storageSync:
                return self.storage.delete(query).andThen(success: { (success) in
                    if let success = success {
                        if success {
                            self.network.delete(query)
                        }
                    }
                })
            }
            }()
    }
}
