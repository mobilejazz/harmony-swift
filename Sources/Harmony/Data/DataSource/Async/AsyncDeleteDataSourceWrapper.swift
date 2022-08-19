//
//  AsyncDeleteDataSourceWrapper.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public class AsyncDeleteDataSourceWrapper<D>: AsyncDeleteDataSource where D: DeleteDataSource{

    private let dataSource: D
    
    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func delete(_ query: Query) async throws {
        try await dataSource.delete(query).async()
    }
    
    public func deleteAll(_ query: Query) async throws {
        try await dataSource.deleteAll(query).async()
    }
}
