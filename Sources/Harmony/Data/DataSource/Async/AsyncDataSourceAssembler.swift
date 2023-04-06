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

///
/// Assambles a CRUD async data source into a single async data source object
///
@available(iOS 13.0.0, *)
public final class AsyncDataSourceAssembler<Get: AsyncGetDataSource, Put: AsyncPutDataSource, Delete: AsyncDeleteDataSource, T>: AsyncGetDataSource, AsyncPutDataSource, AsyncDeleteDataSource where Get.T == T, Put.T == T {
    private let getDataSource: Get
    private let putDataSource: Put
    private let deleteDataSource: Delete

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

    public func get(_ query: Query) async throws -> T {
        return try await getDataSource.get(query)
    }

    public func getAll(_ query: Query) async throws -> [T] {
        return try await getDataSource.getAll(query)
    }

    @discardableResult
    public func put(_ value: T?, in query: Query) async throws -> T {
        return try await putDataSource.put(value, in: query)
    }

    @discardableResult
    public func putAll(_ array: [T], in query: Query) async throws -> [T] {
        return try await putDataSource.putAll(array, in: query)
    }

    public func delete(_ query: Query) async throws {
        return try await deleteDataSource.delete(query)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncDataSourceAssembler where Get == Put, Get == Delete {
    /// Initializer for a single AsyncDataSource
    ///
    /// - Parameter dataSource: The data source
    convenience init(_ dataSource: Get) {
        self.init(get: dataSource, put: dataSource, delete: dataSource)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncDataSourceAssembler where Put == AsyncVoidPutDataSource<T>, Delete == AsyncVoidDeleteDataSource {
    /// Initializer for a single AsyncDataSource
    ///
    /// - Parameter getDataSource: The data source
    convenience init(get getDataSource: Get) {
        self.init(get: getDataSource, put: AsyncVoidPutDataSource(), delete: AsyncVoidDeleteDataSource())
    }
}

@available(iOS 13.0.0, *)
public extension AsyncDataSourceAssembler where Get == AsyncVoidGetDataSource<T>, Delete == AsyncVoidDeleteDataSource {
    /// Initializer for a single AsyncDataSource
    ///
    /// - Parameter putDataSource: The data source
    convenience init(put putDataSource: Put) {
        self.init(get: AsyncVoidGetDataSource(), put: putDataSource, delete: AsyncVoidDeleteDataSource())
    }
}

@available(iOS 13.0.0, *)
public extension AsyncDataSourceAssembler where Get == AsyncVoidGetDataSource<T>, Put == AsyncVoidPutDataSource<T> {
    /// Initializer for a single AsyncDataSource
    ///
    /// - Parameter deleteDataSource: The data source
    convenience init(delete deleteDataSource: Delete) {
        self.init(get: AsyncVoidGetDataSource(), put: AsyncVoidPutDataSource(), delete: deleteDataSource)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncDataSourceAssembler where Get == AsyncVoidGetDataSource<T> {
    /// Initializer for a single AsyncDataSource
    ///
    /// - Parameter putDataSource: The data source
    /// - Parameter deleteDataSource: The data source
    convenience init(put putDataSource: Put, delete deleteDataSource: Delete) {
        self.init(get: AsyncVoidGetDataSource(), put: putDataSource, delete: deleteDataSource)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncDataSourceAssembler where Put == AsyncVoidPutDataSource<T> {
    /// Initializer for a single AsyncDataSource
    ///
    /// - Parameter getDataSource: The data source
    /// - Parameter deleteDataSource: The data source
    convenience init(get getDataSource: Get, delete deleteDataSource: Delete) {
        self.init(get: getDataSource, put: AsyncVoidPutDataSource(), delete: deleteDataSource)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncDataSourceAssembler where Delete == AsyncVoidDeleteDataSource {
    /// Initializer for a single AsyncDataSource
    ///
    /// - Parameter getDataSource: The data source
    /// - Parameter putDataSource: The data source
    convenience init(get getDataSource: Get, put putDataSource: Put) {
        self.init(get: getDataSource, put: putDataSource, delete: AsyncVoidDeleteDataSource())
    }
}
