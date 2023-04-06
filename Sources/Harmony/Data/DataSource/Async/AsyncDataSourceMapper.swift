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
public class AsyncGetDataSourceMapper<R, In, Out>: AsyncGetDataSource where R: AsyncGetDataSource, R.T == In {
    public typealias T = Out

    private let dataSource: R
    private let toOutMapper: Mapper<In, Out>

    public init(dataSource: R, toOutMapper: Mapper<In, Out>) {
        self.dataSource = dataSource
        self.toOutMapper = toOutMapper
    }

    public func get(_ query: Harmony.Query) async throws -> T {
        let value = try await dataSource.get(query)
        return try toOutMapper.map(value)
    }

    public func getAll(_ query: Harmony.Query) async throws -> [T] {
        let values = try await dataSource.getAll(query)
        return try values.map { try toOutMapper.map($0) }
    }
}

@available(iOS 13.0.0, *)

public class AsyncPutDataSourceMapper<R, In, Out>: AsyncPutDataSource where R: AsyncPutDataSource, R.T == In {
    public typealias T = Out

    private let dataSource: R
    private let toInMapper: Mapper<Out, In>
    private let toOutMapper: Mapper<In, Out>

    public init(dataSource: R, toInMapper: Mapper<Out, In>, toOutMapper: Mapper<In, Out>) {
        self.dataSource = dataSource
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }

    public func put(_ value: Out?, in query: Harmony.Query) async throws -> Out {
        var mapped: In?
        if let value {
            mapped = try toInMapper.map(value)
        }
        let value = try await dataSource.put(mapped, in: query)
        return try toOutMapper.map(value)
    }

    public func putAll(_ array: [Out], in query: Harmony.Query) async throws -> [Out] {
        let mappedArray = try array.map { try toInMapper.map($0) }
        let values = try await dataSource.putAll(mappedArray, in: query)
        return try values.map { try toOutMapper.map($0) }
    }
}

@available(iOS 13.0.0, *)
public class AsyncDataSourceMapper<R, In, Out>: AsyncGetDataSource, AsyncPutDataSource, AsyncDeleteDataSource
    where R: AsyncGetDataSource, R: AsyncPutDataSource, R: AsyncDeleteDataSource, R.T == In
// swiftlint:opening_brace
{
    public typealias T = Out

    private let dataSource: R
    private let toInMapper: Mapper<Out, In>
    private let toOutMapper: Mapper<In, Out>

    public init(dataSource: R, toInMapper: Mapper<Out, In>, toOutMapper: Mapper<In, Out>) {
        self.dataSource = dataSource
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }

    public func get(_ query: Harmony.Query) async throws -> T {
        let value = try await dataSource.get(query)
        return try toOutMapper.map(value)
    }

    public func getAll(_ query: Harmony.Query) async throws -> [T] {
        let values = try await dataSource.getAll(query)
        return try values.map { try toOutMapper.map($0) }
    }

    public func put(_ value: Out?, in query: Harmony.Query) async throws -> Out {
        var mapped: In?
        if let value {
            mapped = try toInMapper.map(value)
        }
        let value = try await dataSource.put(mapped, in: query)
        return try toOutMapper.map(value)
    }

    public func putAll(_ array: [Out], in query: Harmony.Query) async throws -> [Out] {
        let mappedArray = try array.map { try toInMapper.map($0) }
        let values = try await dataSource.putAll(mappedArray, in: query)
        return try values.map { try toOutMapper.map($0) }
    }

    public func delete(_ query: Harmony.Query) async throws {
        return try await dataSource.delete(query)
    }
}
