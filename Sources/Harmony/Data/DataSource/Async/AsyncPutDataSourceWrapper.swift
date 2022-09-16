//
//  AssyncPutDataSourceWrapper.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncPutDataSourceWrapper<D,T>: AsyncPutDataSource where D: PutDataSource, D.T == T {
    
    private let dataSource: D
    
    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query) async throws -> T {
        try await self.dataSource.put(value, in: query).async()
    }

    @discardableResult
    public func putAll(_ array: [T], in query: Query) async throws -> [T] {
        try await self.dataSource.putAll(array, in: query).async()
    }
}
