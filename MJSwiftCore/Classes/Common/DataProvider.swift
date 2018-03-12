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

/// DataProvider implementations will have to define custom operations
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
/// Abstract DataProvider
///
open class DataProvider <T> {
    
    /// Main get method
    ///
    /// - Parameters:
    ///   - query: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type list of T
    open func get(_ query: Query, operation: Operation = .none) -> Future<[T]> {
        fatalError("Undefined behavior on method get on class \(String(describing: type(of:self))) for operation \(operation) and query \(String(describing: type(of:query)))")
    }
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func put(_ query: Query, operation: Operation = .none) -> Future<[T]> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method put on \(String(describing: type(of:self)))")
    }
    
    /// Main delete method
    ///
    /// - Parameters:
    ///   - query: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type list of Bool. If the operation succeeds, the future will be resovled with true.
    @discardableResult
    open func delete(_ query: Query, operation: Operation = .none) -> Future<Bool> {
        fatalError("Undefined behavior on method delete on class \(String(describing: type(of:self))) for operation \(operation) and query \(String(describing: type(of:query)))")
    }
}

extension DataProvider {
    
    /// Main get method
    ///
    /// - Parameters:
    ///   - query: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type optional T
    public func get(_ query: Query, operation: Operation = .none) -> Future<T?> {
        return get(query, operation: operation).map { array in
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
    public func put(_ value: T, operation: Operation = .none) -> Future<T> {
        return put([value], operation: operation).map({ (array) -> T in
            return array.first!
        })
    }
    
    /// Put a list of objects method
    ///
    /// - Parameters:
    ///   - values: List of values of type T to be put
    ///   - operation: The operation type
    /// - Returns: A future of type list of T
    @discardableResult
    public func put(_ objects: [T], operation: Operation = .none) -> Future<[T]> {
        return put(ArrayQuery(objects), operation: operation)
    }
    
    @discardableResult
    public func delete(_ entity: T, operation: Operation = .none) -> Future<Bool> {
        return delete([entity], operation: operation)
    }
    
    /// Delete a list of objects
    ///
    /// - Parameters:
    ///   - entities: The query encapsulating the query parameters
    ///   - operation: The operation type
    /// - Returns: A future of type list of Bool. If the operation succeeds, the future will be resovled with true.
    @discardableResult
    public func delete(_ objects: [T], operation: Operation = .none) -> Future<Bool> {
        return delete(ArrayQuery(objects), operation: operation)
    }
}
