//
// Copyright 2022 Mobile Jazz SL
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
public actor AsyncInMemoryDataSource<T>: AsyncGetDataSource, AsyncPutDataSource, AsyncDeleteDataSource {
    private let inMemoryDataSource: AgnosticInMemoryDataSource<T> = .init()
    
    public init() {}
    
    public func get(_ query: Query) async throws -> T {
        return try inMemoryDataSource.get(query)
    }
    
    public func getAll(_ query: Query) async throws -> [T] {
        return try inMemoryDataSource.getAll(query)
    }
    
    public func put(_ value: T?, in query: Query) async throws -> T {
        return try inMemoryDataSource.put(value, in: query)
    }
    
    public func putAll(_ array: [T], in query: Query) async throws -> [T] {
        return try inMemoryDataSource.putAll(array, in: query)
    }
    
    public func delete(_ query: Query) async throws {
        return try inMemoryDataSource.delete(query)
    }
}
