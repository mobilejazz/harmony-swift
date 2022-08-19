//
//  AssyncPutDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

@available(iOS 13.0.0, *)
public protocol AsyncPutDataSource : AsyncDataSource {
    
    associatedtype T
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: Avalue of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func put(_ value: T?, in query: Query) async throws -> T
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A value of [T] type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func putAll(_ array: [T], in query: Query) async throws -> [T]
}
