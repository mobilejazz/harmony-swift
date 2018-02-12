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
public protocol Query { }

/// A query by an id
public class QueryById : Query {
    public let id : String
    public init(_ id: String) {
        self.id = id
    }
}

// All objects query
public class AllObjectsQuery : Query {
    public init() { }
}

/// Abstract definition of a repository
open class Repository<T> {
    
    public init() { }
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    open func getAll(_ query: Query) -> Future<[T]> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method get on \(String(describing: type(of:self)))")
    }
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func put(_ query: Query) -> Future<Bool> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method put on \(String(describing: type(of:self)))")
    }
    
    /// Put a list of objects method
    ///
    /// - Parameter entities: A list of entities to put
    /// - Returns: A future containing the list of updated entites after the put is resolved
    @discardableResult
    open func putAll(_ entities: [T]) -> Future<[T]> {
        fatalError("Undefined implementation for method put on \(String(describing: type(of:self)))")
    }
    
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func delete(_ query: Query) -> Future<Bool> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method delete on \(String(describing: type(of:self)))")
    }
    
    /// Delete objects method
    ///
    /// - Parameter entities: A list of entities to delete
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func deleteAll(_ entities: [T]) -> Future<Bool> {
        fatalError("Undefined implementation method delete on \(String(describing: type(of:self)))")
    }
}

extension Repository {
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of an optional repository's type
    open func get(_ query: Query) -> Future<T?> {
        return self.getAll(query).map { entities in
            return entities.first
        }
    }
    
    /// Put method for a single object
    ///
    /// - Parameter entity: The entity to put
    /// - Returns: A future containing the entity after the put is resolved
    @discardableResult
    open func put(_ entity: T) -> Future<T> {
        return self.putAll([entity]).map { entities in
            return entities.first!
        }
    }
    
    /// Delete a single object
    ///
    /// - Parameter entity: The entity to put
    /// - Returns: A future containing the entity after the put is resolved
    @discardableResult
    open func delete(_ entity: T) -> Future<Bool> {
        return self.deleteAll([entity])
    }
}
