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

public class InMemoryDataSource<T>: GetDataSource, PutDataSource, DeleteDataSource {
    
    private let dataSource = FutureFromAgnosticDataSourceWrapper(datasource: AgnosticInMemoryDataSource<T>())
    
    public init(){
        
    }
        
    public func get(_ query: Query) -> Future<T> {
        return dataSource.get(query)
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        return dataSource.getAll(query)
    }
    
    @discardableResult
    public func put(_ value: T? = nil, in query: Query) -> Future<T> {
        return dataSource.put(value, in: query)
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return dataSource.putAll(array, in: query)
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        return dataSource.delete(query)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        return dataSource.deleteAll(query)
    }
}
