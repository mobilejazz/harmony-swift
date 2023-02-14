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
public class AsyncGetRepositoryMapper<R, In, Out>: AsyncGetRepository where R: AsyncGetRepository, R.T == In {
    public typealias T = Out

    private let repository: R
    private let toOutMapper: Mapper<In, Out>

    public init(repository: R, toOutMapper: Mapper<In, Out>) {
        self.repository = repository
        self.toOutMapper = toOutMapper
    }

    public func get(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> T {
        let value = try await repository.get(query, operation: operation)
        return try toOutMapper.map(value)
    }

    public func getAll(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> [T] {
        let values = try await repository.getAll(query, operation: operation)
        return try values.map { try toOutMapper.map($0) }
    }
}

@available(iOS 13.0.0, *)
public class AsyncPutRepositoryMapper<R, In, Out>: AsyncPutRepository where R: AsyncPutRepository, R.T == In {
    public typealias T = Out

    private let repository: R
    private let toInMapper: Mapper<Out, In>
    private let toOutMapper: Mapper<In, Out>

    public init(repository: R, toInMapper: Mapper<Out, In>, toOutMapper: Mapper<In, Out>) {
        self.repository = repository
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }

    public func put(_ value: Out?, in query: Harmony.Query, operation: Harmony.Operation) async throws -> Out {
        var mapped: In?
        if let value {
            mapped = try toInMapper.map(value)
        }
        let value = try await repository.put(mapped, in: query, operation: operation)
        return try toOutMapper.map(value)
    }

    public func putAll(_ array: [Out], in query: Harmony.Query, operation: Harmony.Operation) async throws -> [Out] {
        let mappedArray = try array.map { try toInMapper.map($0) }
        let values = try await repository.putAll(mappedArray, in: query, operation: operation)
        return try values.map { try toOutMapper.map($0) }
    }
}

@available(iOS 13.0.0, *)
public class AsyncRepositoryMapper<R, In, Out>: AsyncGetRepository, AsyncPutRepository, AsyncDeleteRepository
    where R: AsyncGetRepository, R: AsyncPutRepository, R: AsyncDeleteRepository, R.T == In
// swiftlint:opening_brace
{
    public typealias T = Out

    private let repository: R
    private let toInMapper: Mapper<Out, In>
    private let toOutMapper: Mapper<In, Out>

    public init(repository: R, toInMapper: Mapper<Out, In>, toOutMapper: Mapper<In, Out>) {
        self.repository = repository
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }

    public func get(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> T {
        let value = try await repository.get(query, operation: operation)
        return try toOutMapper.map(value)
    }

    public func getAll(_ query: Harmony.Query, operation: Harmony.Operation) async throws -> [T] {
        let values = try await repository.getAll(query, operation: operation)
        return try values.map { try toOutMapper.map($0) }
    }

    public func put(_ value: Out?, in query: Harmony.Query, operation: Harmony.Operation) async throws -> Out {
        var mapped: In?
        if let value {
            mapped = try toInMapper.map(value)
        }
        let value = try await repository.put(mapped, in: query, operation: operation)
        return try toOutMapper.map(value)
    }

    public func putAll(_ array: [Out], in query: Harmony.Query, operation: Harmony.Operation) async throws -> [Out] {
        let mappedArray = try array.map { try toInMapper.map($0) }
        let values = try await repository.putAll(mappedArray, in: query, operation: operation)
        return try values.map { try toOutMapper.map($0) }
    }

    public func delete(_ query: Harmony.Query, operation: Harmony.Operation) async throws {
        return try await repository.delete(query, operation: operation)
    }
}
