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
/// Generic DataProvider implementation for network an storage operations
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
                return network.getAll(query).flatMap { entities in
                    return self.storage.putAll(entities)
                }
            case .storageSync:
                return storage.getAll(query).flatMap { values -> Future<[E]> in
                    if !self.storageValidation.isArrayValid(values) {
                        return self.network.getAll(query).flatMap { entities in
                            return self.storage.putAll(entities)
                        }
                    } else {
                        return values.toFuture()
                    }
                }
            }
            }().map { a in self.toObjectMapper.map(a) }
    }
    
    @discardableResult
    override public func put(_ query: Query, operation: Operation) -> Future<Bool> {
        return { () -> Future<Bool> in
            switch operation {
            case .network:
                return network.put(query)
            case .storage:
                return storage.put(query)
            case .networkSync:
                return network.put(query).flatMap { succeed in
                    if succeed {
                        return self.storage.put(query)
                    } else {
                        return false.toFuture()
                    }
                }
            case .storageSync:
                return storage.put(query).flatMap { succeed in
                    if succeed {
                        return self.network.put(query)
                    } else {
                        return false.toFuture()
                    }
                }
            }
            }()
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
                return network.putAll(array).flatMap { entities in
                    return self.storage.putAll(entities)
                }
            case .storageSync:
                return storage.putAll(array).flatMap { entities in
                    return self.network.putAll(entities)
                }
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
                return network.deleteAll(entities).flatMap { success in
                    if success {
                        return self.storage.deleteAll(entities)
                    } else {
                        return false.toFuture()
                    }
                }
            case .storageSync:
                return storage.deleteAll(entities).flatMap { success in
                    if success {
                        return self.network.deleteAll(entities)
                    } else {
                        return false.toFuture()
                    }
                }
            }
            }()
    }
}
