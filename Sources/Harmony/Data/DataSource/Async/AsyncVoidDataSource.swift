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

///
/// Async void get data source implementation
///
public class AsyncVoidGetDataSource<T>: AsyncGetDataSource {
    public init() {}
    public func get(_ query: Query) async throws -> T { throw CoreError.NotImplemented() }
    public func getAll(_ query: Query) async throws -> [T] { throw CoreError.NotImplemented() }
}

///
/// Async void put data source implementation
///
public class AsyncVoidPutDataSource<T>: AsyncPutDataSource {
    public func put(_ value: T?, in query: Query) async throws -> T { throw CoreError.NotImplemented() }
    public func putAll(_ array: [T], in query: Query) async throws -> [T] { throw CoreError.NotImplemented() }
}

///
/// Async void delete data source implementation
///
public class AsyncVoidDeleteDataSource: AsyncDeleteDataSource {
    public func delete(_ query: Query) async throws { throw CoreError.NotImplemented() }
}

///
/// Async void data source implementation
///
public class AsyncVoidDataSource<T>: AsyncGetDataSource, AsyncPutDataSource, AsyncDeleteDataSource {
    public init() {}
    public func get(_ query: Query) async throws -> T { throw CoreError.NotImplemented() }
    public func getAll(_ query: Query) async throws -> [T] { throw CoreError.NotImplemented() }
    public func put(_ value: T?, in query: Query) async throws -> T { throw CoreError.NotImplemented() }
    public func putAll(_ array: [T], in query: Query) async throws -> [T] { throw CoreError.NotImplemented() }
    public func delete(_ query: Query) async throws { throw CoreError.NotImplemented() }
}
