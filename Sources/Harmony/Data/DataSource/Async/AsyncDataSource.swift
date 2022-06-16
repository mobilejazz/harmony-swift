//
//  AsyncDataSource.swift
//  Harmony
//
//  Created by Joan Martin on 10/6/22.
//

import Foundation

@available(iOS 13.0.0, *)
public protocol AsyncDataSource {}

@available(iOS 13.0.0, *)
public protocol AsyncGetDataSource : AsyncDataSource {
    
    associatedtype T
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future containing the fetched object or an error .notFound if not found
    func get(_ query: Query) async throws -> T
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    func getAll(_ query: Query) async throws -> [T]
}

// TODO: implement put & delete
