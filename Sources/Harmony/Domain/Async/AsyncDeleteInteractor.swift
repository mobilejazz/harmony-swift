//
//  AsyncDeleteInteractor.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public actor AsyncDeleteInteractor: AsyncInteractor {
    
    private let repository: AsyncAnyDeleteRepository
    
    public init<R>(_ repository: R) where R:AsyncDeleteRepository {
        self.repository = AsyncAnyDeleteRepository(repository)
    }

    public func execute(_ query: Query, _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) async throws {
        try await self.repository.delete(query, operation: operation)
    }
}

@available(iOS 13.0.0, *)
public actor AsyncDeleteAllInteractor: AsyncInteractor {
    
    private let repository: AsyncAnyDeleteRepository
    
    public init<R>(_ repository: R) where R:AsyncDeleteRepository {
        self.repository = AsyncAnyDeleteRepository(repository)
    }

    public func execute(_ query: Query, _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) async throws {
        try await self.repository.deleteAll(query, operation: operation)
    }
}
