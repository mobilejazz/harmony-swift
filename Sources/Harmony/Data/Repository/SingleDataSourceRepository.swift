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
public class SingleGetDataSourceRepository<D: GetDataSource,T> : GetRepository where D.T == T {
    
    private let dataSource : D
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained data source
    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }
    
    public func get(_ query: Query, operation: Operation = DefaultOperation()) -> Future<T> {
        return dataSource.get(query)
    }
    
    public func getAll(_ query: Query, operation: Operation = DefaultOperation()) -> Future<[T]> {
        return dataSource.getAll(query)
    }
}

extension GetDataSource {
    /// Creates a single data source repository from a data source
    ///
    /// - Returns: A SingleGetDataSourceRepository repository
    public func toGetRepository() -> SingleGetDataSourceRepository<Self,T> {
        return SingleGetDataSourceRepository(self)
    }
}

///
/// Single data source repository.
/// All repository methods are directly forwarded to a single data source.
/// Operation parameter is not used in any case.
///
public class SinglePutDataSourceRepository<D: PutDataSource,T> : PutRepository where D.T == T {
    
    private let dataSource : D
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained data source
    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation = DefaultOperation()) -> Future<T> {
        return dataSource.put(value, in: query)
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation = DefaultOperation()) -> Future<[T]> {
        return dataSource.putAll(array, in: query)
    }
}

extension PutDataSource {
    /// Creates a single data source repository from a data source
    ///
    /// - Returns: A SinglePutDataSourceRepository repository
    public func toPutRepository() -> SinglePutDataSourceRepository<Self,T> {
        return SinglePutDataSourceRepository(self)
    }
}

///
/// Single data source repository.
/// All repository methods are directly forwarded to a single data source.
/// Operation parameter is not used in any case.
///
public class SingleDeleteDataSourceRepository<D: DeleteDataSource> : DeleteRepository {
    
    private let dataSource : D
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained data source
    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation = DefaultOperation()) -> Future<Void> {
        return dataSource.delete(query)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation = DefaultOperation()) -> Future<Void> {
        return dataSource.deleteAll(query)
    }
}

extension DeleteDataSource {
    /// Creates a single data source repository from a data source
    ///
    /// - Returns: A SingleDeleteDataSourceRepository repository
    public func toDeleteRepository() -> SingleDeleteDataSourceRepository<Self> {
        return SingleDeleteDataSourceRepository(self)
    }
}

///
/// Single data source repository.
/// All repository methods are directly forwarded to a single data source.
/// Operation parameter is not used in any case.
///
public class SingleDataSourceRepository<D,T> : GetRepository, PutRepository, DeleteRepository where D:GetDataSource, D:PutDataSource, D:DeleteDataSource, D.T == T {
    
    private let dataSource : D
    
    /// Main initializer
    ///
    /// - Parameters:
    ///   - dataSource: The data source
    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }
    
    public func get(_ query: Query, operation: Operation = DefaultOperation()) -> Future<T> {
        return dataSource.get(query)
    }
    
    public func getAll(_ query: Query, operation: Operation = DefaultOperation()) -> Future<[T]> {
        return dataSource.getAll(query)
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation = DefaultOperation()) -> Future<T> {
        return dataSource.put(value, in: query)
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation = DefaultOperation()) -> Future<[T]> {
        return dataSource.putAll(array, in: query)
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation = DefaultOperation()) -> Future<Void> {
        return dataSource.delete(query)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation = DefaultOperation()) -> Future<Void> {
        return dataSource.deleteAll(query)
    }
}
