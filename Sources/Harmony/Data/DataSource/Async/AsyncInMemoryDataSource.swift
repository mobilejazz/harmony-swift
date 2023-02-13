//
// Copyright 2023 Mobile Jazz SL
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

@available(iOS 13.0.0, *)
public class AsyncInMemoryDataSource<T>: AsyncGetDataSource, AsyncPutDataSource, AsyncDeleteDataSource {
    private var objects: [String: T] = [:]
    private var arrays: [String: [T]] = [:]
    
    public init() {}
    
    public func get(_ query: Query) async throws -> T {
        switch query {
        case let query as KeyQuery:
            guard let value = objects[query.key] else {
                throw CoreError.NotFound()
            }
            return value
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func getAll(_ query: Query) async throws -> [T] {
        switch query {
        case is AllObjectsQuery:
            var array = Array(objects.values)
            arrays.values.forEach { a in
                array.append(contentsOf: a)
            }
            return array
        case let query as IdsQuery<String>:
            return objects
                .filter { query.ids.contains($0.key) }
                .map { $0.value }
        case let query as KeyQuery:
            if let value = arrays[query.key] {
                return value
            }
            throw CoreError.NotFound()
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func put(_ value: T?, in query: Query) async throws -> T {
        switch query {
        case let query as KeyQuery:
            guard let value = value else {
                throw CoreError.IllegalArgument("Value cannot be nil")
            }
            arrays.removeValue(forKey: query.key)
            objects[query.key] = value
            return value
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func putAll(_ array: [T], in query: Query) async throws -> [T] {
        switch query {
        case let query as IdsQuery<String>:
            guard array.count == query.ids.count else {
                throw CoreError.IllegalArgument("Array lenght must be equal to query.ids length")
            }
            array.enumerated().forEach { offset, element in
                arrays.removeValue(forKey: query.ids[offset])
                objects[query.ids[offset]] = element
            }
            return array
        case let query as KeyQuery:
            objects.removeValue(forKey: query.key)
            arrays[query.key] = array
            return array
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func delete(_ query: Query) async throws {
        switch query {
        case is AllObjectsQuery:
            objects.removeAll()
            arrays.removeAll()
        case let query as IdsQuery<String>:
            query.ids.forEach { key in
                objects.removeValue(forKey: key)
                arrays.removeValue(forKey: key)
            }
        case let query as KeyQuery:
            objects.removeValue(forKey: query.key)
            arrays.removeValue(forKey: query.key)
        default:
            throw CoreError.QueryNotSupported()
        }
    }
}
