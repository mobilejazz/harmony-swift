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
import Harmony

/// A GetDataSource spy that records all calls.
public class GetDataSourceSpy <D: GetDataSource, T> : GetDataSource where D.T == T {

    public private(set) var getCalls: [Query] = []
    public private(set) var getAllCalls: [Query] = []

    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func get(_ query: Query) -> Future<T> {
        getCalls.append(query)
        return dataSource.get(query)
    }

    public func getAll(_ query: Query) -> Future<[T]> {
        getAllCalls.append(query)
        return dataSource.getAll(query)
    }
}

/// A PutDataSource spy that records all calls.
public class PutDataSourceSpy <D: PutDataSource, T> : PutDataSource where D.T == T {

    public private(set) var putCalls: [(value: T?, query: Query)] = []
    public private(set) var putAllCalls: [(array: [T], query: Query)] = []

    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func put(_ value: T?, in query: Query) -> Future<T> {
        putCalls.append((value, query))
        return dataSource.put(value, in: query)
    }

    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        putAllCalls.append((array, query))
        return dataSource.putAll(array, in: query)
    }
}

/// A DeleteDataSource spy that records all calls.
public class DeleteDataSourceSpy <D: DeleteDataSource>: DeleteDataSource {

    public private(set) var deleteCalls: [Query] = []
    public private(set) var deleteAllCalls: [Query] = []

    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func delete(_ query: Query) -> Future<Void> {
        deleteCalls.append(query)
        return dataSource.delete(query)
    }

    public func deleteAll(_ query: Query) -> Future<Void> {
        deleteAllCalls.append(query)
        return dataSource.deleteAll(query)
    }
}

/// A DataSource spy that records all calls.
public class DataSourceSpy <D, T> : GetDataSource, PutDataSource, DeleteDataSource where D: GetDataSource, D: PutDataSource, D: DeleteDataSource, D.T == T {

    public private(set) var getCalls: [Query] = []
    public private(set) var getAllCalls: [Query] = []

    private let dataSource: D

    public init(_ dataSource: D) {
        self.dataSource = dataSource
    }

    public func get(_ query: Query) -> Future<T> {
        getCalls.append(query)
        return dataSource.get(query)
    }

    public func getAll(_ query: Query) -> Future<[T]> {
        getAllCalls.append(query)
        return dataSource.getAll(query)
    }

    public private(set) var putCalls: [(value: T?, query: Query)] = []
    public private(set) var putAllCalls: [(array: [T], query: Query)] = []

    public func put(_ value: T?, in query: Query) -> Future<T> {
        putCalls.append((value, query))
        return dataSource.put(value, in: query)
    }

    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        putAllCalls.append((array, query))
        return dataSource.putAll(array, in: query)
    }

    public private(set) var deleteCalls: [Query] = []
    public private(set) var deleteAllCalls: [Query] = []

    public func delete(_ query: Query) -> Future<Void> {
        deleteCalls.append(query)
        return dataSource.delete(query)
    }

    public func deleteAll(_ query: Query) -> Future<Void> {
        deleteAllCalls.append(query)
        return dataSource.deleteAll(query)
    }
}
