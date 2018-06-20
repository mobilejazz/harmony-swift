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
/// Single data source repository.
/// All repository methods are directly forwarded to a single data source.
/// Operation parameter is not used in any case.
///
public class SingleDataSourceRepository<T> : Repository {

    private let dataSource : AnyDataSource<T>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained data source
    public init<D>(_ dataSource: D) where D : DataSource, D.T == T {
        self.dataSource = dataSource.asAnyDataSource()
    }
    
    public func get(_ query: Query, operation: Operation = BlankOperation()) -> Future<T> {
        return dataSource.get(query)
    }
    
    public func getAll(_ query: Query, operation: Operation = BlankOperation()) -> Future<[T]> {
        return dataSource.getAll(query)
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation = BlankOperation()) -> Future<T> {
        return dataSource.put(value, in: query)
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation = BlankOperation()) -> Future<[T]> {
        return dataSource.putAll(array, in: query)
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation = BlankOperation()) -> Future<Void> {
        return dataSource.delete(query)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation = BlankOperation()) -> Future<Void> {
        return dataSource.deleteAll(query)
    }
}

extension DataSource {
    /// Creates a single data source repository from a data source
    ///
    /// - Returns: A SingleDataSourceRepository repository
    public func toRepository() -> AnyRepository<T> {
        return SingleDataSourceRepository(self).asAnyRepository()
    }
}
