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

public enum RepositoryCRUD : CustomStringConvertible {
    case get
    case getAll
    case put
    case putAll
    case delete
    case deleteAll
    case custom(String)
    
    public var description: String {
        switch self {
        case .get: return "get"
        case .getAll: return "getAll"
        case .put: return "put"
        case .putAll: return "putAll"
        case .delete: return "delete"
        case .deleteAll: return "deleteAll"
        case .custom(let string): return string
        }
    }
}

///
/// An operation defines an abstraction on how data must be fetched (to which DataSource<T> a query must be forwarded).
///
public protocol Operation { }

extension Operation {
    public func fatalError<R>(_ method: RepositoryCRUD, _ origin: R) -> Never where R : TypedRepository {
        Swift.fatalError("Undefined operation \(String(describing: self)) for method \(method) on \(String(describing: type(of: origin)))")
    }
}

/// An empty operation definition
public class BlankOperation : Operation {
    public init() { }
}

public protocol TypedRepository {
    associatedtype T
}

public protocol GetRepository : TypedRepository {
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

public protocol PutRepository : TypedRepository {
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    func put(_ value: T?, in query: Query, operation: Operation) -> Future<T>
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
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

public protocol DeleteRepository : TypedRepository {
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    func delete(_ query: Query, operation: Operation) -> Future<Void>
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
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

///
/// Abstract definition of a repository.
/// A Repository<T> is responsible to forward a query to a specific DataSource<T>.
/// Each repository subclass must extend the Operation struct with its own operations, then override any needed method
/// from the Repository<T> superclass and forward the query to the desired DataSource<T>.
///
public protocol Repository : GetRepository, PutRepository, DeleteRepository { }

///
/// Blank repository superclass implementation
///
public class BlankRepositoryBase<T> : TypedRepository {
    private let crash : Bool
    public init(crash : Bool = true) { self.crash = crash }
    
    internal func crashOrError(_ operation: Operation) -> Error {
        if crash {
            operation.fatalError(.get, self)
        } else {
            return CoreError.NotImplemented()
        }
    }
}

///
/// Blank get repository implementation
///
public class BlankGetRepository<T> : BlankRepositoryBase<T>, GetRepository {
    public func get(_ query: Query, operation: Operation) -> Future<T> { return Future(crashOrError(operation)) }
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> { return Future(crashOrError(operation)) }
}

///
/// Blank put repository implementation
///
public class BlankPutRepository<T> : BlankRepositoryBase<T>, PutRepository {
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> { return Future(crashOrError(operation)) }
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> { return Future(crashOrError(operation)) }
}

///
/// Blank delete repository implementation
///
public class BlankDeleteRepository<T> : BlankRepositoryBase<T>, DeleteRepository {
    public func delete(_ query: Query, operation: Operation) -> Future<Void> { return Future(crashOrError(operation)) }
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> { return Future(crashOrError(operation)) }
}

///
/// Blank repository implementation
///
public class BlankRepository<T> : BlankRepositoryBase<T>, Repository {
    public func get(_ query: Query, operation: Operation) -> Future<T> { return Future(crashOrError(operation)) }
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> { return Future(crashOrError(operation)) }
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> { return Future(crashOrError(operation)) }
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> { return Future(crashOrError(operation)) }
    public func delete(_ query: Query, operation: Operation) -> Future<Void> { return Future(crashOrError(operation)) }
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> { return Future(crashOrError(operation)) }
}

