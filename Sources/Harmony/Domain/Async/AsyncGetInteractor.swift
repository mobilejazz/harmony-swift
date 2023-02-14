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
public actor AsyncGetInteractor<T>: AsyncInteractor {
    private let repository: AsyncAnyGetRepository<T>

    public init<R>(_ repository: R) where R: AsyncGetRepository, R.T == T {
        self.repository = AsyncAnyGetRepository(repository)
    }

    public func execute(_ query: Query = VoidQuery(), _ operation: Operation = DefaultOperation()) async throws -> T {
        try await repository.get(query, operation: operation)
    }
}

@available(iOS 13.0.0, *)
public actor AsyncGetAllInteractor<T>: AsyncInteractor {
    private let repository: AsyncAnyGetRepository<T>

    public init<R>(_ repository: R) where R: AsyncGetRepository, R.T == T {
        self.repository = AsyncAnyGetRepository(repository)
    }

    public func execute(_ query: Query = VoidQuery(), _ operation: Operation = DefaultOperation()) async throws -> [T] {
        try await repository.getAll(query, operation: operation)
    }
}
