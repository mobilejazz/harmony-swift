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
    case storage
    case networkSync
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
    open func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        fatalError("Undefined behavior on method get on class \(String(describing: type(of:self))) for operation \(operation) and query \(String(describing: type(of:query)))")
    }
    
    /// Main put method
    ///
    /// - Parameters:
    ///   - values: List of values of type T to be put
    ///   - operation: The operation type
    /// - Returns: A future of type list of T
    @discardableResult
    open func putAll(_ objects: [T], operation: Operation) -> Future<[T]> {
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
    
    /// Delete a list of objects
    ///
    /// - Parameters:
    ///   - entities: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type list of Bool. If the operation succeeds, the future will be resovled with true.
    @discardableResult
    open func deleteAll(_ objects: [T], operation: Operation) -> Future<Bool> {
        fatalError("Undefined behavior on method delete on class \(String(describing: type(of:self))) for operation \(operation)")
    }
}

extension DataProvider {
    
    /// Main get method
    ///
    /// - Parameters:
    ///   - query: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type optional T
    open func get(_ query: Query, operation: Operation) -> Future<T?> {
        return getAll(query, operation: operation).map{ array in
            return array.first
        }
    }
    
    /// Custom put for a single value
    ///
    /// - Parameters:
    ///   - value: The value of type T to be put
    ///   - operation: The operation type
    /// - Returns: A future of type T
    @discardableResult
    open func put(_ value: T, operation: Operation) -> Future<T> {
        return putAll([value], operation: operation).map({ (array) -> T in
            return array.first!
        })
    }
    
    @discardableResult
    open func delete(_ entity: T, operation: Operation) -> Future<Bool> {
        return deleteAll([entity], operation: operation)
    }
}

public protocol ObjectValidation {
    func isObjectValid<T>(_ object: T) -> Bool
    func isArrayValid<T>(_ objects: [T]?) -> Bool
}

public extension ObjectValidation {
    
    /// Validator method for arrays
    ///
    /// The validation process iterates over the array and is considered valid if all objects are valid.
    /// Note that:
    ///   - An empty array is considered invalid
    ///   - A nil instance is considered invalid
    ///
    /// - Parameter object: The object to validate.
    /// - Returns: true if valid, false otherwise.
    public func isArrayValid<T>(_ objects: [T]?) -> Bool {
        if let objects = objects {
            if objects.isEmpty {
                return false
            }
            for object in objects {
                if !isObjectValid(object) {
                    return false
                }
            }
            return true
        } else {
            return true
        }
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
    private let storageValidation: ObjectValidation
    
    public init(network: Repository<E>,
                storage: Repository<E>,
                storageValidation: ObjectValidation,
                toEntityMapper: Mapper<O, E>,
                toObjectMapper: Mapper<E, O>) {
        self.network = network
        self.storage = storage
        self.storageValidation = storageValidation
        self.toEntityMapper = toEntityMapper
        self.toObjectMapper = toObjectMapper
    }
    
    override public func getAll(_ query: Query, operation: Operation) -> Future<[O]> {
        return { () -> Future<[E]> in
            switch operation {
            case .network:
                return network.getAll(query)
            case .storage:
                return storage.getAll(query)
            case .networkSync:
                return network.getAll(query).andThen(success: { entities in
                    self.storage.putAll(entities)
                })
            case .storageSync:
                return storage.getAll(query).flatMap { values -> Future<[E]> in
                    if !self.storageValidation.isArrayValid(values) {
                        return self.network.getAll(query).andThen(success: { entities in
                            self.storage.putAll(entities)
                        })
                    } else {
                        return Future(values)
                    }
                }
            }
            }().map { a in self.toObjectMapper.map(a) }
    }
    
    @discardableResult
    override public func putAll(_ objects: [O], operation: Operation) -> Future<[O]> {
        let array = objects.map { o in toEntityMapper.map(o) }
        return { () -> Future<[E]> in
            switch operation {
            case .network:
                return network.putAll(array)
            case .storage:
                return storage.putAll(array)
            case .networkSync:
                return network.putAll(array).andThen(success: { entities in
                    self.storage.putAll(entities)
                })
            case .storageSync:
                return storage.putAll(array).andThen(success: { entities in
                    self.network.putAll(entities)
                })
            }
            }().map { a in self.toObjectMapper.map(a) }
    }
    
    @discardableResult
    override public func delete(_ query: Query, operation: Operation) -> Future<Bool> {
        return { () -> Future<Bool> in
            switch operation {
            case .network:
                return network.delete(query)
            case .storage:
                return storage.delete(query)
            case .networkSync:
                return network.delete(query).andThen(success: { success in
                    if success {
                        self.storage.delete(query)
                    }
                })
            case .storageSync:
                return storage.delete(query).andThen(success: { success in
                    if success {
                        self.network.delete(query)
                    }
                })
            }
            }()
    }
    
    @discardableResult
    override public func deleteAll(_ objects: [O], operation: Operation) -> Future<Bool> {
        let entities = objects.map { o in toEntityMapper.map(o) }
        return { () -> Future<Bool> in
            switch operation {
            case .network:
                return network.deleteAll(entities)
            case .storage:
                return storage.deleteAll(entities)
            case .networkSync:
                return network.deleteAll(entities).andThen(success: { success in
                    if success {
                        self.storage.deleteAll(entities)
                    }
                })
            case .storageSync:
                return storage.deleteAll(entities).andThen(success: { success in
                    if success {
                        self.network.deleteAll(entities)
                    }
                })
            }
            }()
    }
}
