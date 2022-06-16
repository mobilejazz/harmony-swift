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

public protocol Repository { }

public protocol GetRepository : Repository {
    
    associatedtype T
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of an optional repository's type
    func get(_ query: Query, operation: Operation) -> Future<T>
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    func getAll(_ query: Query, operation: Operation) -> Future<[T]>
}

extension GetRepository {
    public func get<K>(_ id: K, operation: Operation) -> Future<T> where K:Hashable {
        return get(IdQuery(id), operation: operation)
    }
    
    public func getAll<K>(_ id: K, operation: Operation) -> Future<[T]> where K:Hashable {
        return getAll(IdQuery(id), operation: operation)
    }
}

public protocol PutRepository : Repository {
    
    associatedtype T
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func put(_ value: T?, in query: Query, operation: Operation) -> Future<T>
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]>
}

extension PutRepository {
    @discardableResult
    public func put<K>(_ value: T?, forId id: K, operation: Operation) -> Future<T> where K:Hashable {
        return put(value, in: IdQuery(id), operation: operation)
    }
    
    @discardableResult
    public func putAll<K>(_ array: [T], forId id: K, operation: Operation) -> Future<[T]> where K:Hashable {
        return putAll(array, in: IdQuery(id), operation: operation)
    }
}

public protocol DeleteRepository : Repository {
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Void type.
    @discardableResult
    func delete(_ query: Query, operation: Operation) -> Future<Void>
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Void type.
    @discardableResult
    func deleteAll(_ query: Query, operation: Operation) -> Future<Void>
}

extension DeleteRepository {
    @discardableResult
    public func delete<K>(_ id: K, operation: Operation) -> Future<Void> where K:Hashable {
        return delete(IdQuery(id), operation: operation)
    }
    
    @discardableResult
    public func deleteAll<K>(_ id: K, operation: Operation) -> Future<Void> where K:Hashable {
        return deleteAll(IdQuery(id), operation: operation)
    }
}

public enum RepositoryCRUD : CustomStringConvertible {
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

extension Operation {
    public func fatalError<R>(_ method: RepositoryCRUD, _ origin: R) -> Never where R : Repository {
        Swift.fatalError("Undefined operation \(String(describing: self)) for method \(method) on \(String(describing: type(of: origin)))")
    }
}
