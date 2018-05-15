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

///
/// An operation defines an abstraction on how data must be fetched (to which DataSource<T> a query must be forwarded).
///
public struct Operation : RawRepresentable, Equatable, Hashable, CustomStringConvertible {
    public typealias RawValue = String
    public var rawValue: String
    public var hashValue: Int { return rawValue.hashValue }
    public static func ==(lhs: Operation, rhs: Operation) -> Bool { return lhs.rawValue == rhs.rawValue }
    public init(rawValue: String) { self.rawValue = rawValue }
    public var description: String { return rawValue }

    /// None operation
    public static let none = Operation(rawValue:"none")
}

///
/// Abstract definition of a repository.
/// A Repository<T> is responsible to forward a query to a specific DataSource<T>.
/// Each repository subclass must extend the Operation struct with its own operations, then override any needed method
/// from the Repository<T> superclass and forward the query to the desired DataSource<T>.
///
open class Repository<T> {
    
    public init() { }
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of an optional repository's type
    open func get(_ query: Query, operation: Operation) -> Future<T> {
        switch operation {
        default:
            fatalError("Undefined operation \(operation.rawValue) for method get on \(String(describing: type(of:self)))")
        }
    }
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    open func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        default:
            fatalError("Undefined operation \(operation.rawValue) for method getAll on \(String(describing: type(of:self)))")
        }
    }
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        switch operation {
        default:
            fatalError("Undefined operation \(operation.rawValue) for method put on \(String(describing: type(of:self)))")
        }
    }
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        default:
            fatalError("Undefined operation \(operation.rawValue) for method putAll on \(String(describing: type(of:self)))")
        }
    }
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func delete(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        default:
            fatalError("Undefined operation \(operation.rawValue) for method delete on \(String(describing: type(of:self)))")
        }
    }
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        default:
            fatalError("Undefined operation \(operation.rawValue) for method deleteAll on \(String(describing: type(of:self)))")
        }
    }
}

extension Repository {
    public func get<K>(_ id: K, operation: Operation = .none) -> Future<T> where K:Hashable {
        return get(QueryById(id), operation: operation)
    }
    
    public func getAll<K>(_ id: K, operation: Operation = .none) -> Future<[T]> where K:Hashable {
        return getAll(QueryById(id), operation: operation)
    }
    
    @discardableResult
    public func put<K>(_ value: T?, forId id: K, operation: Operation = .none) -> Future<T> where K:Hashable {
        return put(value, in: QueryById(id), operation: operation)
    }
    
    @discardableResult
    public func putAll<K>(_ array: [T], forId id: K, operation: Operation = .none) -> Future<[T]> where K:Hashable {
        return putAll(array, in: QueryById(id), operation: operation)
    }
    
    @discardableResult
    public func delete<K>(_ id: K, operation: Operation = .none) -> Future<Void> where K:Hashable {
        return delete(QueryById(id), operation: operation)
    }
    
    @discardableResult
    public func deleteAll<K>(_ id: K, operation: Operation = .none) -> Future<Void> where K:Hashable {
        return deleteAll(QueryById(id), operation: operation)
    }
}
