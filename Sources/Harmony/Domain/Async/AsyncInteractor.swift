//
//  AsyncInteractor.swift
//  Harmony
//
//  Created by Joan Martin on 10/6/22.
//

import Foundation

// Namespace definition
@available(iOS 13.0.0, *)
protocol AsyncInteractor { }

@available(iOS 13.0.0, *)
public actor GetInteractor<T>: AsyncInteractor {
    
    private let repository: AsyncAnyGetRepository<T>
    
    public init<R>(_ repository: R) where R:AsyncGetRepository, R.T == T {
        self.repository = AsyncAnyGetRepository(repository)
    }

    public func execute(_ query: Query = VoidQuery(), _ operation: Operation = DefaultOperation()) async throws -> T {
        try await self.repository.get(query, operation: operation)
    }
}

// TODO: implement put & delete
