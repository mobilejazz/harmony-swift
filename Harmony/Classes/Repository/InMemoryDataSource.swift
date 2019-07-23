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

public class InMemoryDataSource<T> : GetDataSource, PutDataSource, DeleteDataSource  {
    
    private var objects : [String : T] = [:]
    private var arrays : [String : [T]] = [:]
    
    public init() {}
    
    public func get(_ query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            guard let value = objects[query.key] else {
                return Future(CoreError.NotFound())
            }
            return Future(value)
        default:
            query.fatalError(.get, self)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        switch query {
        case is AllObjectsQuery:
            var array = Array(objects.values)
            arrays.values.forEach { a in
                array.append(contentsOf: a)
            }
            return Future(array)
        case let query as IdsQuery<String>:
            return Future(objects.filter { query.ids.contains($0.key) }.map { $0.value })
        case let query as KeyQuery:
            if let value = arrays[query.key] {
                return Future(value)
            }
            return Future(CoreError.NotFound())
        default:
            query.fatalError(.getAll, self)
        }
    }
    
    @discardableResult
    public func put(_ value: T? = nil, in query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            guard let value = value else {
                return Future(CoreError.IllegalArgument("Value cannot be nil"))
            }
            objects[query.key] = value
            return Future(value)
        default:
            query.fatalError(.put, self)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        switch query {
        case let query as IdsQuery<String>:
            guard array.count == query.ids.count else {
                return Future(CoreError.IllegalArgument("Array lenght must be equal to query.ids length"))
            }
            array.enumerated().forEach { (offset, element) in
                objects[query.ids[offset]] = element
            }
            return Future(array)
        case let query as KeyQuery:
            arrays[query.key] = array
            return Future(array)
        default:
            query.fatalError(.putAll, self)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            objects[query.key] = nil
            return Future(Void())
        default:
            query.fatalError(.delete, self)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as IdsQuery<String>:
            query.ids.forEach { key in
                objects[key] = nil
            }
            return Future(Void())
        case is AllObjectsQuery:
            objects.removeAll()
            arrays.removeAll()
            return Future(Void())
        case let query as KeyQuery:
            arrays[query.key] = nil
            return Future(Void())
        default:
            query.fatalError(.deleteAll, self)
        }
    }
}
