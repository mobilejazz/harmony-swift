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

/// Default query interface
public protocol Query { }

/// Blank query
public class BlankQuery : Query {
    public init() {}
}

/// A query by an id
public class QueryById <T> where T:Hashable {
    public let id : T
    public init(_ id: T) {
        self.id = id
    }
}

/// All objects query
public class AllObjectsQuery : Query {
    public init() { }
}

///
/// Abstract definition of a DataSource
///
open class DataSource <T> {
    
    public init() { }
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of an optional repository's type
    open func get(_ query: Query) -> Future<T?> {
        switch query {
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method get on \(String(describing: type(of:self)))")
        }
    }
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    open func getAll(_ query: Query) -> Future<[T]> {
        switch query {
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method getAll on \(String(describing: type(of:self)))")
        }
    }
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func put(_ value: T?, in query: Query) -> Future<T> {
        switch query {
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method put on \(String(describing: type(of:self)))")
        }
    }
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        switch query {
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method putAll on \(String(describing: type(of:self)))")
        }
    }
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func delete(_ value: T?, in query: Query = BlankQuery()) -> Future<Void> {
        switch query {
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method delete on \(String(describing: type(of:self)))")
        }
    }
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func deleteAll(_ array: [T], in query: Query) -> Future<Void> {
        switch query {
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method deleteAll on \(String(describing: type(of:self)))")
        }
    }
}

extension DataSource {
    public func get<K>(_ id: K) -> Future<T?> where K:Hashable {
        return get(QueryById(id))
    }
    
    public func getAll<K>(_ id: K) -> Future<[T]> where K:Hashable {
        return getAll(QueryById(id))
    }
    
    @discardableResult
    public func put<K>(_ value: T?, forId id: K) -> Future<T> where K:Hashable {
        return put(value, in: QueryById(id))
    }
    
    @discardableResult
    public func putAll<K>(_ array: [T], forId id: K) -> Future<[T]> where K:Hashable {
        return putAll(array, in: QueryById(id))
    }
    
    @discardableResult
    public func delete<K>(_ value: T?, forId id: K) -> Future<Void> where K:Hashable {
        return delete(value, in: QueryById(id))
    }
    
    @discardableResult
    public func deleteAll<K>(_ array: [T], forId id: K) -> Future<Void> where K:Hashable {
        return deleteAll(array, in: QueryById(id))
    }
}

