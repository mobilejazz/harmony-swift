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
public class AsyncGetDataSourceWrapper<D, T>: AsyncGetDataSource where D: GetDataSource, D.T == T {
    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func get(_ query: Query) async throws -> T {
        try await dataSource.get(query).async()
    }

    public func getAll(_ query: Query) async throws -> [T] {
        try await dataSource.getAll(query).async()
    }
}

@available(iOS 13.0.0, *)
public class AsyncPutDataSourceWrapper<D, T>: AsyncPutDataSource where D: PutDataSource, D.T == T {
    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    @discardableResult
    public func put(_ value: T?, in query: Query) async throws -> T {
        try await dataSource.put(value, in: query).async()
    }

    @discardableResult
    public func putAll(_ array: [T], in query: Query) async throws -> [T] {
        try await dataSource.putAll(array, in: query).async()
    }
}

@available(iOS 13.0.0, *)
public class AsyncDeleteDataSourceWrapper<D>: AsyncDeleteDataSource where D: DeleteDataSource {
    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func delete(_ query: Query) async throws {
        try await dataSource.delete(query).async()
    }
}

// swiftlint:disable line_length
@available(iOS 13.0.0, *)
public class AsyncDataSourceWrapper<D, T>: AsyncGetDataSource, AsyncPutDataSource, AsyncDeleteDataSource where D: GetDataSource, D: PutDataSource, D: DeleteDataSource, D.T == T {
    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func get(_ query: Query) async throws -> T {
        try await dataSource.get(query).async()
    }

    public func getAll(_ query: Query) async throws -> [T] {
        try await dataSource.getAll(query).async()
    }

    @discardableResult
    public func put(_ value: T?, in query: Query) async throws -> T {
        try await dataSource.put(value, in: query).async()
    }

    @discardableResult
    public func putAll(_ array: [T], in query: Query) async throws -> [T] {
        try await dataSource.putAll(array, in: query).async()
    }

    public func delete(_ query: Query) async throws {
        try await dataSource.delete(query).async()
    }
}
