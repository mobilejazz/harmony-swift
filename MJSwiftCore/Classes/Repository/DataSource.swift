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

public protocol DataSource { }

///
/// Interface for a Get data source.
///
public protocol GetDataSource : DataSource {
    
    associatedtype T
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future containing the fetched object or an error .notFound if not found
    func get(_ query: Query) -> Future<T>
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    func getAll(_ query: Query) -> Future<[T]>
}

extension GetDataSource {
    public func get<K>(_ id: K) -> Future<T> where K:Hashable {
        return get(IdQuery(id))
    }
    
    public func getAll<K>(_ id: K) -> Future<[T]> where K:Hashable {
        return getAll(IdQuery(id))
    }
}

///
/// Interface for a Put data source.
///
public protocol PutDataSource : DataSource {
    
    associatedtype T
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func put(_ value: T?, in query: Query) -> Future<T>
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func putAll(_ array: [T], in query: Query) -> Future<[T]>
}

extension PutDataSource {
    @discardableResult
    public func put<K>(_ value: T?, forId id: K) -> Future<T> where K:Hashable {
        return put(value, in: IdQuery(id))
    }
    
    @discardableResult
    public func putAll<K>(_ array: [T], forId id: K) -> Future<[T]> where K:Hashable {
        return putAll(array, in: IdQuery(id))
    }
}

///
/// Interface for a Delete data source.
///
public protocol DeleteDataSource : DataSource {
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Void type.
    @discardableResult
    func delete(_ query: Query) -> Future<Void>
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Void type.
    @discardableResult
    func deleteAll(_ query: Query) -> Future<Void>
}

extension DeleteDataSource {
    @discardableResult
    public func delete<K>(_ id: K) -> Future<Void> where K:Hashable {
        return delete(IdQuery(id))
    }
    
    @discardableResult
    public func deleteAll<K>(_ id: K) -> Future<Void> where K:Hashable {
        return deleteAll(IdQuery(id))
    }
}

public enum DataSourceCRUD : CustomStringConvertible {
    case get
    case getAll
    case put
    case putAll
    case delete
    case deleteAll
    
    public var description: String {
        switch self {
        case .get: return "get"
        case .getAll: return "getAll"
        case .put: return "put"
        case .putAll: return "putAll"
        case .delete: return "delete"
        case .deleteAll: return "deleteAll"
        }
    }
}

extension Query {
    public func fatalError<D>(_ method: DataSourceCRUD, _ origin: D) -> Never where D : DataSource {
        Swift.fatalError("Undefined query \(String(describing: self)) for method \(method) on \(String(describing: type(of: origin)))")
    }
}
