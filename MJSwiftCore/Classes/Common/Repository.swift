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

/// Default query interface
public protocol Query {
    func map<A,B>(_ mapper: Mapper<A,B>) -> Query
}

extension Query {
    /// Default implementation returns self
    public func map<A,B>(_ mapper: Mapper<A,B>) -> Query {
        return self
    }
}

/// A query by an id
public class QueryById : Query {
    public let id : String
    public init(_ id: String) {
        self.id = id
    }
}

/// All objects query
public class AllObjectsQuery : Query {
    public init() { }
}

/// Key based query
public class KeyQuery : Query {
    public let key : String
    public init(_ key: String) {
        self.key = key
    }
    // Method definition is done because KeyValueQuery subclass must implement it
    public func map<A,B>(_ mapper: Mapper<A,B>) -> Query { return self }
}

/// Key-value based query
public class KeyValueQuery<T> : KeyQuery {
    public let value : T
    public init(_ key: String, _ value: T) {
        self.value = value
        super.init(key)
    }
    public override func map<A,B>(_ mapper: Mapper<A,B>) -> Query {
        return KeyValueQuery<B>(key, mapper.map(self.value as! A))
    }
}

/// Array query
public class ArrayQuery<T> : Query {
    public let array : [T]
    public init(_ array : [T]) {
        self.array = array
    }
    public func map<A,B>(_ mapper: Mapper<A,B>) -> Query {
        return ArrayQuery<B>(mapper.map(self.array as! [A]))
    }
}

/// Abstract definition of a repository
open class Repository<T> {
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    open func get(_ query: Query) -> Future<[T]> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method get on \(String(describing: type(of:self)))")
    }
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func put(_ query: Query) -> Future<[T]> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method put on \(String(describing: type(of:self)))")
    }
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func delete(_ query: Query) -> Future<Bool> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method delete on \(String(describing: type(of:self)))")
    }
}

extension Repository {
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of an optional repository's type
    public func get(_ query: Query) -> Future<T?> {
        return self.get(query).map { entities in
            return entities.first
        }
    }
    
    /// Put method for a single object
    ///
    /// - Parameter entity: The entity to put
    /// - Returns: A future containing the entity after the put is resolved
    @discardableResult
    public func put(_ entity: T) -> Future<T> {
        return self.put([entity]).map { entities in
            return entities.first!
        }
    }
    
    /// Put a list of objects method
    ///
    /// - Parameter entities: A list of entities to put
    /// - Returns: A future containing the list of updated entites after the put is resolved
    @discardableResult
    public func put(_ entities: [T]) -> Future<[T]> {
        return self.put(ArrayQuery(entities))
    }
    
    /// Delete a single object
    ///
    /// - Parameter entity: The entity to put
    /// - Returns: A future containing the entity after the put is resolved
    @discardableResult
    public func delete(_ entity: T) -> Future<Bool> {
        return self.delete([entity])
    }
    
    // Delete objects method
    ///
    /// - Parameter entities: A list of entities to delete
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    public func delete(_ entities: [T]) -> Future<Bool> {
        return self.delete(ArrayQuery(entities))
    }
}
