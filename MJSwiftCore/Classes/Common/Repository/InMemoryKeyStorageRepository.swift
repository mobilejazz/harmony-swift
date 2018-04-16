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

public class InMemoryKeyStorageRepository <T> : Repository <T> {
    
    private let dictionary : [AnyHashable : T] = [:]
    
    public override func get(_ query: Query, operation: Operation = .blank) -> Future<T?> {
        switch query {
        case is QueryById<String>:
            return Future(nil)
        default:
            return super.get(query, operation: operation)
        }
    }
    
    public override func getAll(_ query: Query, operation: Operation = .blank) -> Future<[T]> {
        switch query {
        case is BlankQuery:
            return Future([])
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method getAll on \(String(describing: type(of:self)))")
        }
    }
    
    @discardableResult
    public override func put(_ value: T, in query: Query = BlankQuery(), operation: Operation = .blank) -> Future<T> {
        switch query {
        case is BlankQuery:
            return Future(value)
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method put on \(String(describing: type(of:self)))")
        }
    }
    
    @discardableResult
    public override func putAll(_ array: [T], in query: Query = BlankQuery(), operation: Operation = .blank) -> Future<[T]> {
        switch query {
        case is BlankQuery:
            return Future(array)
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method putAll on \(String(describing: type(of:self)))")
        }
    }

    @discardableResult
    public override func delete(_ value: T? = nil, in query: Query = BlankQuery(), operation: Operation = .blank) -> Future<Bool> {
        switch query {
        case is BlankQuery:
            return Future(false)
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method delete on \(String(describing: type(of:self)))")
        }
    }
    
    @discardableResult
    public override func deleteAll(_ array: [T] = [], in query: Query = BlankQuery(), operation: Operation = .blank) -> Future<Bool> {
        switch query {
        case is BlankQuery:
            return Future(false)
        default:
            fatalError("Undefined query class \(String(describing: type(of:query))) for method deleteAll on \(String(describing: type(of:self)))")
        }
    }
}
