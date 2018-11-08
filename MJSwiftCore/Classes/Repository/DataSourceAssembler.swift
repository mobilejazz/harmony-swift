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
/// Assambles a CRUD data source into a single data source object
///
public final class DataSourceAssembler <Get : GetDataSource, Put: PutDataSource, Delete: DeleteDataSource, T> : GetDataSource, PutDataSource, DeleteDataSource where Get.T == T, Put.T == T {
    
    private let getDataSource : Get
    private let putDataSource : Put
    private let deleteDataSource : Delete
    
    /// Main initializer
    ///
    /// - Parameters:
    ///   - getDataSource: The get data source
    ///   - putDataSource: The put data source
    ///   - deleteDataSource: The delete data source
    public init(get getDataSource: Get, put putDataSource: Put, delete deleteDataSource: Delete) {
        self.getDataSource = getDataSource
        self.putDataSource = putDataSource
        self.deleteDataSource = deleteDataSource
    }
    
    public func get(_ query: Query) -> Future<T> {
        return getDataSource.get(query)
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        return getDataSource.getAll(query)
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query) -> Future<T> {
        return putDataSource.put(value, in: query)
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return putDataSource.putAll(array, in: query)
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        return deleteDataSource.delete(query)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        return deleteDataSource.deleteAll(query)
    }
}

extension DataSourceAssembler where Get == Put, Get == Delete {
    /// Initializer for a single DataSource
    ///
    /// - Parameter dataSource: The data source
    public convenience init(_ dataSource: Get) {
        self.init(get: dataSource, put: dataSource, delete: dataSource)
    }
}

extension DataSourceAssembler where Put == VoidPutDataSource<T>, Delete == VoidDeleteDataSource {
    /// Initializer for a single DataSource
    ///
    /// - Parameter getDataSource: The data source
    public convenience init(get getDataSource: Get) {
        self.init(get: getDataSource, put: VoidPutDataSource(), delete: VoidDeleteDataSource())
    }
}

extension DataSourceAssembler where Get == VoidGetDataSource<T>, Delete == VoidDeleteDataSource {
    /// Initializer for a single DataSource
    ///
    /// - Parameter putDataSource: The data source
    public convenience init(put putDataSource: Put) {
        self.init(get: VoidGetDataSource(), put: putDataSource, delete: VoidDeleteDataSource())
    }
}

extension DataSourceAssembler where Get == VoidGetDataSource<T>, Put == VoidPutDataSource<T> {
    /// Initializer for a single DataSource
    ///
    /// - Parameter deleteDataSource: The data source
    public convenience init(delete deleteDataSource: Delete) {
        self.init(get: VoidGetDataSource(), put: VoidPutDataSource(), delete: deleteDataSource)
    }
}

extension DataSourceAssembler where Get == VoidGetDataSource<T> {
    /// Initializer for a single DataSource
    ///
    /// - Parameter putDataSource: The data source
    /// - Parameter deleteDataSource: The data source
    public convenience init(put putDataSource: Put, delete deleteDataSource: Delete) {
        self.init(get: VoidGetDataSource(), put: putDataSource, delete: deleteDataSource)
    }
}

extension DataSourceAssembler where Put == VoidPutDataSource<T> {
    /// Initializer for a single DataSource
    ///
    /// - Parameter getDataSource: The data source
    /// - Parameter deleteDataSource: The data source
    public convenience init(get getDataSource: Get, delete deleteDataSource: Delete) {
        self.init(get: getDataSource, put: VoidPutDataSource(), delete: deleteDataSource)
    }
}

extension DataSourceAssembler where Delete == VoidDeleteDataSource {
    /// Initializer for a single DataSource
    ///
    /// - Parameter getDataSource: The data source
    /// - Parameter putDataSource: The data source
    public convenience init(get getDataSource: Get, put putDataSource: Put) {
        self.init(get: getDataSource, put: putDataSource, delete: VoidDeleteDataSource())
    }
}
