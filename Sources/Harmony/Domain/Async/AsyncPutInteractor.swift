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
public actor AsyncPutInteractor<T>: AsyncInteractor {
    private let repository: AsyncAnyPutRepository<T>

    public init<R>(_ repository: R) where R: AsyncPutRepository, R.T == T {
        self.repository = AsyncAnyPutRepository(repository)
    }

    public func execute(_ value: T? = nil, query: Query = VoidQuery(), _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) async throws -> T {
        try await repository.put(value, in: query, operation: operation)
    }
}

@available(iOS 13.0.0, *)
public actor AsyncPutAllInteractor<T>: AsyncInteractor {
    private let repository: AsyncAnyPutRepository<T>

    public init<R>(_ repository: R) where R: AsyncPutRepository, R.T == T {
        self.repository = AsyncAnyPutRepository(repository)
    }

    public func execute(_ array: [T] = [], query: Query = VoidQuery(), _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) async throws -> [T] {
        try await repository.putAll(array, in: query, operation: operation)
    }
}
