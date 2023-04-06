//
// Copyright 2022 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

@available(iOS 13.0.0, *)
public protocol AsyncDataSource {}

@available(iOS 13.0.0, *)
public protocol AsyncGetDataSource: AsyncDataSource {
    associatedtype T

    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: The fetched object or it throws if not found
    func get(_ query: Query) async throws -> T

    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: An array of values or it throws if not found
    func getAll(_ query: Query) async throws -> [T]
}

@available(iOS 13.0.0, *)
public protocol AsyncPutDataSource: AsyncDataSource {
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

@available(iOS 13.0.0, *)
public protocol AsyncDeleteDataSource: AsyncDataSource {
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    func delete(_ query: Query) async throws
}
