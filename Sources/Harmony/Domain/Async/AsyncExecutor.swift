//
//  AsyncExecutor.swift
//  Harmony
//
//  Created by Joan Martin on 10/6/22.
//

import Foundation

@available(iOS 13.0.0, *)
public protocol AsyncExecutor {
    associatedtype T
    func submit(operation: @escaping () async throws -> T) async throws -> T
}

@available(iOS 13.0.0, *)
public actor AsyncDicrectExecutor<T>: AsyncExecutor {
    public func submit(operation: @escaping () async throws -> T) async throws -> T {
        try await operation()
    }
}

@available(iOS 13.0.0, *)
public actor AsyncAtomicExecutor<T>: AsyncExecutor  {
    private enum Status {
        case idle
        case executing(Task<T,Error>)
    }
    private var status: Status = .idle
    
    public func submit(operation: @escaping () async throws -> T) async throws -> T {
        switch status {
        case .idle:
            let task: Task<T,Error> = Task {
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
