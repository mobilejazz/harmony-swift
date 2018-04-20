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

/// Protocol to use a query as a key for a key value interface
public protocol KeyValueQuery : Query {
    var key : String { get }
}

extension QueryById : KeyValueQuery {
    public var key : String {
        get {
            switch T.self {
            case is String.Type:
                return id as! String
            case is Int.Type:
                return "\(id as! Int)"
            default:
                return "\(id.hashValue)"
            }
        }
    }
}

extension AllObjectsQuery : KeyValueQuery {
    public var key : String { get { return "allObjects" } }
}

///
/// Key-value based repository to store data in a key value interface.
/// The repository only works with QueryById
///
public class KeyValueRepository <T> : Repository<T> {
    
    private let keyValueService : KeyValueInterface<T>
    
    /// Default initializer
    ///
    /// - Parameter keyValueService: The key value service to be used
    public init(_ keyValueService : KeyValueInterface<T>) {
        self.keyValueService = keyValueService
    }
    
    private func keyFromQuery(_ query: Query) -> String? {
        if case let query as KeyValueQuery = query.self {
            return query.key
        }
        return nil
    }
    
    public override func get(_ query: Query, operation: Operation = .blank) -> Future<T?> {
        guard let key = keyFromQuery(query) else {
            return super.get(query, operation: operation)
        }
        return Future(keyValueService.get(key))
    }
    
    public override func getAll(_ query: Query, operation: Operation = .blank) -> Future<[T]> {
        guard let key = keyFromQuery(query) else {
            return super.getAll(query, operation: operation)
        }
        if let array = keyValueService.getAll(key) {
            return Future(array)
        } else {
            return Future([])
        }
    }
    
    public override func put(_ value: T, in query: Query, operation: Operation = .blank) -> Future<T> {
        guard let key = keyFromQuery(query) else {
            return super.put(value, in: query, operation: operation)
        }
        keyValueService.set(value, forKey: key)
        return Future(value)
    }
    
    public override func putAll(_ array: [T], in query: Query, operation: Operation = .blank) -> Future<[T]> {
        guard let key = keyFromQuery(query) else {
            return super.putAll(array, in: query, operation: operation)
        }
        keyValueService.setAll(array, forKey: key)
        return Future(array)
    }
    
    public override func delete(_ value: T?, in query: Query, operation: Operation = .blank) -> Future<Bool> {
        guard let key = keyFromQuery(query) else {
            return super.delete(value, in: query, operation: operation)
        }
        keyValueService.delete(key)
        return Future(true)
    }
    
    public override func deleteAll(_ array: [T], in query: Query, operation: Operation = .blank) -> Future<Bool> {
        guard let key = keyFromQuery(query) else {
            return super.deleteAll(array, in: query, operation: operation)
        }
        keyValueService.delete(key)
        return Future(true)
    }
}

