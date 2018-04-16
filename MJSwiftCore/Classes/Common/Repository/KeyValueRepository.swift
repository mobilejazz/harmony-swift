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

///
/// Key-value based repository to store data in UserDefaults.
/// The repository only works with QueryById and KeyValueQuery types.
///
public class KeyValueRepository <T> : Repository<T> {
    
    private let keyValueService : KeyValueInterface<T>
    private let keyPrefix : String

    public init(_ keyValueService : KeyValueInterface<T>, keyPrefix: String = "") {
        self.keyValueService = keyValueService
        if keyPrefix.count > 0 {
            self.keyPrefix = keyPrefix + "."
        } else {
            self.keyPrefix = ""
        }
    }
    
    private func keyFromQuery(_ query: Query) -> String? {
        switch query.self {
        case is QueryById<String>:
            return keyPrefix + (query as! QueryById<String>).id
        case is AllObjectsQuery:
            return keyPrefix + String(describing:T.self) + ".allObjects"
        default:
            return nil
        }
    }
    
    public override func get(_ query: Query, operation: Operation) -> Future<T?> {
        guard let key = keyFromQuery(query) else {
            return super.get(query, operation: operation)
        }
        let value = keyValueService.get(key)
        return Future(value)
    }
    
    public override func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        guard let key = keyFromQuery(query) else {
            return super.getAll(query, operation: operation)
        }
        let array = keyValueService.getAll(key)
        if let array = array {
            return Future(array)
        } else {
            return Future([])
        }
    }
    
    public override func put(_ value: T, in query: Query, operation: Operation) -> Future<T> {
        guard let key = keyFromQuery(query) else {
            return super.put(value, in: query, operation: operation)
        }
        keyValueService.set(value, forKey: key)
        return Future(value)
    }
    
    public override func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        guard let key = keyFromQuery(query) else {
            return super.putAll(array, in: query, operation: operation)
        }
        keyValueService.setAll(array, forKey: key)
        return Future(array)
    }
    
    public override func delete(_ value: T?, in query: Query, operation: Operation) -> Future<Bool> {
        guard let key = keyFromQuery(query) else {
            return super.delete(value, in: query, operation: operation)
        }
        keyValueService.delete(key)
        return Future(true)
    }
    
    public override func deleteAll(_ array: [T], in query: Query, operation: Operation) -> Future<Bool> {
        guard let key = keyFromQuery(query) else {
            return super.deleteAll(array, in: query, operation: operation)
        }
        keyValueService.delete(key)
        return Future(true)
    }
}

