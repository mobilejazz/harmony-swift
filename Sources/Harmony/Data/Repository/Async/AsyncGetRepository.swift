//
//  AsyncRepository.swift
//  Harmony
//
//  Created by Joan Martin on 10/6/22.
//

import Foundation

@available(iOS 13.0.0, *)
public protocol AsyncRepository { }

@available(iOS 13.0.0, *)
public protocol AsyncGetRepository : AsyncRepository {
    
    associatedtype T
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of an optional repository's type
    func get(_ query: Query, operation: Operation) async throws -> T
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    func getAll(_ query: Query, operation: Operation) async throws -> [T]
}
