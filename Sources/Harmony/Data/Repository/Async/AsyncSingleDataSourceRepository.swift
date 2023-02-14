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
public class AsyncSingleGetDataSourceRepository<D, T>: AsyncGetRepository where D: AsyncGetDataSource, D.T == T {
    private let dataSource: D
    public init(dataSource: D) {
        self.dataSource = dataSource
    }

    public func get(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> T {
        return try await dataSource.get(query)
    }

    public func getAll(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> [T] {
        return try await dataSource.getAll(query)
    }
}

@available(iOS 13.0.0, *)
public class AsyncSinglePutDataSourceRepository<D, T>: AsyncPutRepository where D: AsyncPutDataSource, D.T == T {
    private let dataSource: D
    public init(dataSource: D) {
        self.dataSource = dataSource
    }

    public func put(_ value: T?, in query: Harmony.Query, operation: Harmony.Operation) async throws -> T {
        return try await dataSource.put(value, in: query)
    }

    public func putAll(_ array: [T], in query: Harmony.Query, operation: Harmony.Operation) async throws -> [T] {
        return try await dataSource.putAll(array, in: query)
    }
}

@available(iOS 13.0.0, *)
public class AsyncSingleDeleteDataSourceRepository<D>: AsyncDeleteRepository where D: AsyncDeleteDataSource {
    private let dataSource: D
    public init(dataSource: D) {
        self.dataSource = dataSource
    }

    public func delete(_ query: Harmony.Query, operation: Harmony.Operation) async throws {
        return try await dataSource.delete(query)
    }
}

@available(iOS 13.0.0, *)
public class AsyncSingleDataSourceRepository<D, T>: AsyncGetRepository, AsyncPutRepository, AsyncDeleteRepository
    where D: AsyncGetDataSource, D: AsyncPutDataSource, D: AsyncDeleteDataSource, D.T == T
// swiftlint:disable opening_brace
{
    private let dataSource: D
    public init(dataSource: D) {
        self.dataSource = dataSource
    }

    public func get(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> T {
        return try await dataSource.get(query)
    }

    public func getAll(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> [T] {
        return try await dataSource.getAll(query)
    }

    public func put(_ value: T?, in query: Harmony.Query, operation: Harmony.Operation) async throws -> T {
        return try await dataSource.put(value, in: query)
    }

    public func putAll(_ array: [T], in query: Harmony.Query, operation: Harmony.Operation) async throws -> [T] {
        return try await dataSource.putAll(array, in: query)
    }

    public func delete(_ query: Harmony.Query, operation: Harmony.Operation) async throws {
        return try await dataSource.delete(query)
    }
}
