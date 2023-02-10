//
// Copyright 2023 Mobile Jazz SL
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
/// Async void get repository implementation
///
public class AsyncVoidGetRepository<T>: AsyncGetRepository {
    public init() {}
    public func get(_ query: Query, operation: Operation) async throws -> T { throw CoreError.NotImplemented() }
    public func getAll(_ query: Query, operation: Operation) async throws -> [T] { throw CoreError.NotImplemented() }
}

///
/// Async void put repository implementation
///
public class AsyncVoidPutRepository<T>: AsyncPutRepository {
    public init() {}
    public func put(_ value: T?, in query: Query, operation: Operation) async throws -> T { throw CoreError.NotImplemented() }
    public func putAll(_ array: [T], in query: Query, operation: Operation) async throws -> [T] { throw CoreError.NotImplemented() }
}

///
/// Async void delete repository implementation
///
public class AsyncVoidDeleteRepository: AsyncDeleteRepository {
    public init() {}
    public func delete(_ query: Query, operation: Operation) async throws { throw CoreError.NotImplemented() }
}

///
/// Async void repository implementation
///
public class AsyncVoidRepository<T>: AsyncGetRepository, AsyncPutRepository, AsyncDeleteRepository {
    public init() {}
    public func get(_ query: Query, operation: Operation) async throws -> T { throw CoreError.NotImplemented() }
    public func getAll(_ query: Query, operation: Operation) async throws -> [T] { throw CoreError.NotImplemented() }
    public func put(_ value: T?, in query: Query, operation: Operation) async throws -> T { throw CoreError.NotImplemented() }
    public func putAll(_ array: [T], in query: Query, operation: Operation) async throws -> [T] { throw CoreError.NotImplemented() }
    public func delete(_ query: Query, operation: Operation) async throws { throw CoreError.NotImplemented() }
}
