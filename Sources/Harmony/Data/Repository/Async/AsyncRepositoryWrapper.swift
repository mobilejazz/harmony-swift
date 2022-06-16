//
//  AsyncRepositoryWrapper.swift
//  Harmony
//
//  Created by Joan Martin on 10/6/22.
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncGetRepositoryWrapper<R,T>: AsyncGetRepository where R: GetRepository, R.T == T {
    
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

// TODO: implement put & delete
