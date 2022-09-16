//
//  AsyncDeleteDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public protocol AsyncDeleteDataSource : AsyncDataSource {

    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    func delete(_ query: Query) async throws
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    func deleteAll(_ query: Query) async throws
}
