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
public class AsyncGetRepositoryWrapper<R, T>: AsyncGetRepository where R: GetRepository, R.T == T {
    private let repository: R

    public init(_ repository: R) {
        self.repository = repository
    }

    public func get(_ query: Query, operation: Operation) async throws -> T {
        try await repository.get(query, operation: operation).async()
    }

    public func getAll(_ query: Query, operation: Operation) async throws -> [T] {
        try await repository.getAll(query, operation: operation).async()
    }
}

@available(iOS 13.0.0, *)
public class AsyncPutRepositoryWrapper<R, T>: AsyncPutRepository where R: PutRepository, R.T == T {
    private let repository: R

    public init(_ repository: R) {
        self.repository = repository
    }

    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation) async throws -> T {
        try await repository.put(value, in: query, operation: operation).async()
    }

    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation) async throws -> [T] {
        try await repository.putAll(array, in: query, operation: operation).async()
    }
}

@available(iOS 13.0.0, *)
public class AsyncDeleteRepositoryWrapper<R, T>: AsyncDeleteRepository where R: DeleteRepository {
    private let repository: R

    public init(_ repository: R) {
        self.repository = repository
    }

    public func delete(_ query: Query, operation: Operation) async throws {
        try await repository.delete(query, operation: operation).async()
    }
}
