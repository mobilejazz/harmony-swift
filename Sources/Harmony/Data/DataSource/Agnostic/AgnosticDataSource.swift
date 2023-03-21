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

internal protocol AgnosticDataSource {}

internal protocol AgnosticGetDataSource: AgnosticDataSource {
    associatedtype T

    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: The fetched object or it throws if not found
    func get(_ query: Query) throws -> T

    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: An array of values or it throws if not found
    func getAll(_ query: Query) throws -> [T]
}

internal protocol AgnosticPutDataSource: AgnosticDataSource {
    associatedtype T

    /// Put by query method
    ///
    /// - Parameter value: The value to be put
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: Avalue of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func put(_ value: T?, in query: Query) throws -> T

    /// Put by query method
    ///
    /// - Parameter array: The array of values to be put
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A value of [T] type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func putAll(_ array: [T], in query: Query) throws -> [T]
}

internal protocol AgnosticDeleteDataSource: AgnosticDataSource {
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    func delete(_ query: Query) throws
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    @available(*, deprecated, message: "Use delete with AllObjectsQuery to remove all entries or with any other Query to remove one or more entries")
    func deleteAll(_ query: Query) throws
}
