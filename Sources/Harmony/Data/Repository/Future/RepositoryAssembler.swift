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
/// Assambles a CRUD repository into a single repository object
///
public final class RepositoryAssembler <Get: GetRepository, Put: PutRepository, Delete: DeleteRepository, T> : GetRepository, PutRepository, DeleteRepository where Get.T == T, Put.T == T {
    
    private let getRepository : Get
    private let putRepository : Put
    private let deleteRepository : Delete
    
    /// Main initializer
    ///
    /// - Parameters:
    ///   - getRepository: The get repository
    ///   - putRepository: The put repository
    ///   - deleteRepository: The delete repository
    public init(get getRepository: Get, put putRepository: Put, delete deleteRepository: Delete) {
        self.getRepository = getRepository
        self.putRepository = putRepository
        self.deleteRepository = deleteRepository
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        return getRepository.get(query, operation: operation)
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        return getRepository.getAll(query, operation: operation)
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return putRepository.put(value, in: query, operation: operation)
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return putRepository.putAll(array, in: query, operation: operation)
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return deleteRepository.delete(query, operation: operation)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return deleteRepository.deleteAll(query, operation: operation)
    }
}

extension RepositoryAssembler where Get == Put, Get == Delete {
    /// Initializer for a single Repository
    ///
    /// - Parameter repository: The repository
    public convenience init(_ repository: Get) {
        self.init(get: repository, put: repository, delete: repository)
    }
}

extension RepositoryAssembler where Put == VoidPutRepository<T>, Delete == VoidDeleteRepository {
    /// Initializer for a single Repository
    ///
    /// - Parameter getRepository: The repository
    public convenience init(get getRepository: Get) {
        self.init(get: getRepository, put: VoidPutRepository(), delete: VoidDeleteRepository())
    }
}

extension RepositoryAssembler where Get == VoidGetRepository<T>, Delete == VoidDeleteRepository {
    /// Initializer for a single Repository
    ///
    /// - Parameter putRepository: The repository
    public convenience init(put putRepository: Put) {
        self.init(get: VoidGetRepository(), put: putRepository, delete: VoidDeleteRepository())
    }
}

extension RepositoryAssembler where Get == VoidGetRepository<T>, Put == VoidPutRepository<T> {
    /// Initializer for a single Repository
    ///
    /// - Parameter deleteRepository: The repository
    public convenience init(delete deleteRepository: Delete) {
        self.init(get: VoidGetRepository(), put: VoidPutRepository(), delete: deleteRepository)
    }
}

extension RepositoryAssembler where Get == VoidGetRepository<T> {
    /// Initializer for a single Repository
    ///
    /// - Parameter putRepository: The repository
    /// - Parameter deleteRepository: The repository
    public convenience init(put putRepository: Put, delete deleteRepository: Delete) {
        self.init(get: VoidGetRepository(), put: putRepository, delete: deleteRepository)
    }
}

extension RepositoryAssembler where Put == VoidPutRepository<T> {
    /// Initializer for a single Repository
    ///
    /// - Parameter getRepository: The repository
    /// - Parameter deleteRepository: The repository
    public convenience init(get getRepository: Get, delete deleteRepository: Delete) {
        self.init(get: getRepository, put: VoidPutRepository(), delete: deleteRepository)
    }
}

extension RepositoryAssembler where Delete == VoidDeleteRepository {
    /// Initializer for a single Repository
    ///
    /// - Parameter getRepository: The repository
    /// - Parameter putRepository: The repository
    public convenience init(get getRepository: Get, put putRepository: Put) {
        self.init(get: getRepository, put: putRepository, delete: VoidDeleteRepository())
    }
}
