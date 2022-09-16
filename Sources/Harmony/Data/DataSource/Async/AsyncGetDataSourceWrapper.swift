//
//  AsyncDataSourceWrapper.swift
//  Harmony
//
//  Created by Joan Martin on 10/6/22.
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncGetDataSourceWrapper<D,T>: AsyncGetDataSource where D: GetDataSource, D.T == T {
    
    private let dataSource: D
    
    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }
    
    public func get(_ query: Query) async throws -> T {
        try await dataSource.get(query).async()
    }

    public func getAll(_ query: Query) async throws -> [T] {
        try await dataSource.getAll(query).async()
    }
}
