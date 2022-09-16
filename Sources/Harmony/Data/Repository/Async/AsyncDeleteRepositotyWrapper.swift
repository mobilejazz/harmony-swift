//
//  AsyncDeleteRepositotyWrapper.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncDeleteRepositoryWrapper<R,T>: AsyncDeleteRepository where R: DeleteRepository {
    
    private let repository: R
    
    public init(_ repository: R) {
        self.repository = repository
    }

    public func delete(_ query: Query, operation: Operation) async throws {
        try await repository.delete(query, operation: operation).async()
    }
    
    public func deleteAll(_ query: Query, operation: Operation) async throws {
        try await repository.deleteAll(query, operation: operation).async()
    }
}
