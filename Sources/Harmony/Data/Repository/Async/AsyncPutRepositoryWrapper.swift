//
//  AsyncPutRepositoryWrapper.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncPutRepositoryWrapper<R,T>: AsyncPutRepository where R: PutRepository, R.T == T {
    
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
