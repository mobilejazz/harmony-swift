//
//  AsyncPutInteractor.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public actor AsyncPutInteractor<T>: AsyncInteractor {
    
    private let repository: AsyncAnyPutRepository<T>
    
    public init<R>(_ repository: R) where R:AsyncPutRepository, R.T == T {
        self.repository = AsyncAnyPutRepository(repository)
    }

    public func execute(_ value: T? = nil, query: Query = VoidQuery(), _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) async throws -> T {
        try await self.repository.put(value, in: query, operation: operation)
    }
}

@available(iOS 13.0.0, *)
public actor AsyncPutAllInteractor<T>: AsyncInteractor {
    
    private let repository: AsyncAnyPutRepository<T>
    
    public init<R>(_ repository: R) where R:AsyncPutRepository, R.T == T {
        self.repository = AsyncAnyPutRepository(repository)
    }

    public func execute(_ array: [T] = [], query: Query = VoidQuery(), _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) async throws -> [T] {
        try await self.repository.putAll(array, in: query, operation: operation)
    }
}
