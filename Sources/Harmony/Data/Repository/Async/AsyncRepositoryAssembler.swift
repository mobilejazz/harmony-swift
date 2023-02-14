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
public final class AsyncRepositoryAssembler<Get: AsyncGetRepository, Put: AsyncPutRepository, Delete: AsyncDeleteRepository, T>: AsyncGetRepository, AsyncPutRepository, AsyncDeleteRepository where Get.T == T, Put.T == T {
    private let getRepository: Get
    private let putRepository: Put
    private let deleteRepository: Delete

    /// Main initializer
    ///
    /// - Parameters:
    ///   - getRepository: The get data source
    ///   - putRepository: The put data source
    ///   - deleteRepository: The delete data source
    public init(get getRepository: Get, put putRepository: Put, delete deleteRepository: Delete) {
        self.getRepository = getRepository
        self.putRepository = putRepository
        self.deleteRepository = deleteRepository
    }

    public func get(_ query: Query, operation: Harmony.Operation) async throws -> T {
        return try await getRepository.get(query, operation: operation)
    }

    public func getAll(_ query: Query, operation: Harmony.Operation) async throws -> [T] {
        return try await getRepository.getAll(query, operation: operation)
    }

    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Harmony.Operation) async throws -> T {
        return try await putRepository.put(value, in: query, operation: operation)
    }

    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Harmony.Operation) async throws -> [T] {
        return try await putRepository.putAll(array, in: query, operation: operation)
    }

    public func delete(_ query: Query, operation: Harmony.Operation) async throws {
        return try await deleteRepository.delete(query, operation: operation)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncRepositoryAssembler where Get == Put, Get == Delete {
    /// Initializer for a single AsyncRepository
    ///
    /// - Parameter dataSource: The data source
    convenience init(_ dataSource: Get) {
        self.init(get: dataSource, put: dataSource, delete: dataSource)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncRepositoryAssembler where Put == AsyncVoidPutRepository<T>, Delete == AsyncVoidDeleteRepository {
    /// Initializer for a single AsyncRepository
    ///
    /// - Parameter getRepository: The data source
    convenience init(get getRepository: Get) {
        self.init(get: getRepository, put: AsyncVoidPutRepository(), delete: AsyncVoidDeleteRepository())
    }
}

@available(iOS 13.0.0, *)
public extension AsyncRepositoryAssembler where Get == AsyncVoidGetRepository<T>, Delete == AsyncVoidDeleteRepository {
    /// Initializer for a single AsyncRepository
    ///
    /// - Parameter putRepository: The data source
    convenience init(put putRepository: Put) {
        self.init(get: AsyncVoidGetRepository(), put: putRepository, delete: AsyncVoidDeleteRepository())
    }
}

@available(iOS 13.0.0, *)
public extension AsyncRepositoryAssembler where Get == AsyncVoidGetRepository<T>, Put == AsyncVoidPutRepository<T> {
    /// Initializer for a single AsyncRepository
    ///
    /// - Parameter deleteRepository: The data source
    convenience init(delete deleteRepository: Delete) {
        self.init(get: AsyncVoidGetRepository(), put: AsyncVoidPutRepository(), delete: deleteRepository)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncRepositoryAssembler where Get == AsyncVoidGetRepository<T> {
    /// Initializer for a single AsyncRepository
    ///
    /// - Parameter putRepository: The data source
    /// - Parameter deleteRepository: The data source
    convenience init(put putRepository: Put, delete deleteRepository: Delete) {
        self.init(get: AsyncVoidGetRepository(), put: putRepository, delete: deleteRepository)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncRepositoryAssembler where Put == AsyncVoidPutRepository<T> {
    /// Initializer for a single AsyncRepository
    ///
    /// - Parameter getRepository: The data source
    /// - Parameter deleteRepository: The data source
    convenience init(get getRepository: Get, delete deleteRepository: Delete) {
        self.init(get: getRepository, put: AsyncVoidPutRepository(), delete: deleteRepository)
    }
}

@available(iOS 13.0.0, *)
public extension AsyncRepositoryAssembler where Delete == AsyncVoidDeleteRepository {
    /// Initializer for a single AsyncRepository
    ///
    /// - Parameter getRepository: The data source
    /// - Parameter putRepository: The data source
    convenience init(get getRepository: Get, put putRepository: Put) {
        self.init(get: getRepository, put: putRepository, delete: AsyncVoidDeleteRepository())
    }
}
