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
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func put(_ query: Query, operation: Operation) -> Future<Bool> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method put on \(String(describing: type(of:self)))")
    }
    
    /// Put a list of objects method
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
