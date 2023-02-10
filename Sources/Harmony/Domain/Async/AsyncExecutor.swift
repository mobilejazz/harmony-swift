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

/// Abstract definition of an async executor.
@available(iOS 13.0.0, *)
public protocol AsyncExecutor {
    associatedtype T
    func submit(operation: @escaping () async throws -> T) async throws -> T
}

/// Direct execution of the operation block.
@available(iOS 13.0.0, *)
public class AsyncDicrectExecutor<T>: AsyncExecutor {
    public func submit(operation: @escaping () async throws -> T) async throws -> T {
        try await operation()
    }
}

/// Calls in the main thread (main actor) the operation block.
@available(iOS 13.0.0, *)
public class AsyncMainExecutor<T>: AsyncExecutor {
    public func submit(operation: @escaping () async throws -> T) async throws -> T {
        let task = Task { @MainActor in
            try await operation()
        }
        return try await task.value
    }
}

/// Synchronizes a block execution of async calls.
/// Concurrent calls of `submit` will result in serial exeution of their block code.
@available(iOS 13.0.0, *)
public actor AsyncAtomicExecutor<T>: AsyncExecutor {
    private enum Status {
        case idle
        case executing(Task<T, Error>)
    }

    private var status: Status = .idle

    public init() {}

    public func submit(operation: @escaping () async throws -> T) async throws -> T {
        switch status {
        case .idle:
            let task: Task<T, Error> = Task {
                let value = try await operation()
                self.status = .idle
                return value
            }
            status = .executing(task)
            return try await task.value

        case .executing(let task):
            // Waiting for the previous task to finish
            _ = try? await task.value
            // Checking for cancellation
            try Task.checkCancellation()
            // Re-submit the operation
            return try await submit(operation: operation)
        }
    }
}
