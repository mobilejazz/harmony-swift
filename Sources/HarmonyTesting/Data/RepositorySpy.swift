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

/// A GetRepository spy that records all calls.
public class GetRepositorySpy<D: GetRepository, T>: GetRepository where D.T == T {
    public private(set) var getCalls: [(query: Query, operation: Harmony.Operation)] = []
    public private(set) var getAllCalls: [(query: Query, operation: Harmony.Operation)] = []
    
    private let repository: D
    
    public init(_ dataSource: D) {
        self.repository = dataSource
    }
    
    public func get(_ query: Query, operation: Harmony.Operation) -> Future<T> {
        getCalls.append((query, operation))
        return repository.get(query, operation: operation)
    }
    
    public func getAll(_ query: Query, operation: Harmony.Operation) -> Future<[T]> {
        getAllCalls.append((query, operation))
        return repository.getAll(query, operation: operation)
    }
}

/// A PutRepository spy that records all calls.
public class PutRepositorySpy<D: PutRepository, T>: PutRepository where D.T == T {
    public private(set) var putCalls: [(value: T?, query: Query, operation: Harmony.Operation)] = []
    public private(set) var putAllCalls: [(array: [T], query: Query, operation: Harmony.Operation)] = []
    
    private let repository: D
    
    public init(_ dataSource: D) {
        self.repository = dataSource
    }
    
    public func put(_ value: T?, in query: Query, operation: Harmony.Operation) -> Future<T> {
        putCalls.append((value, query, operation))
        return repository.put(value, in: query, operation: operation)
    }
    
    public func putAll(_ array: [T], in query: Query, operation: Harmony.Operation) -> Future<[T]> {
        putAllCalls.append((array, query, operation))
        return repository.putAll(array, in: query, operation: operation)
    }
}

/// A DeleteRepository spy that records all calls.
public class DeleteRepositorySpy<D: DeleteRepository>: DeleteRepository {
    public private(set) var deleteCalls: [(query: Query, operation: Harmony.Operation)] = []
    public private(set) var deleteAllCalls: [(query: Query, operation: Harmony.Operation)] = []
    
    private let repository: D
    
    public init(_ dataSource: D) {
        self.repository = dataSource
    }
    
    public func delete(_ query: Query, operation: Harmony.Operation) -> Future<Void> {
        deleteCalls.append((query, operation))
        return repository.delete(query, operation: operation)
    }
    
    public func deleteAll(_ query: Query, operation: Harmony.Operation) -> Future<Void> {
        deleteAllCalls.append((query, operation))
        return repository.deleteAll(query, operation: operation)
    }
}

/// A Repository spy that records all calls.
public class RepositorySpy<D, T>: GetRepository, PutRepository, DeleteRepository where D: GetRepository, D: PutRepository, D: DeleteRepository, D.T == T {
    public private(set) var getCalls: [(query: Query, operation: Harmony.Operation)] = []
    public private(set) var getAllCalls: [(query: Query, operation: Harmony.Operation)] = []
    
    private let repository: D
    
    public init(_ dataSource: D) {
        self.repository = dataSource
    }
    
    public func get(_ query: Query, operation: Harmony.Operation) -> Future<T> {
        getCalls.append((query, operation))
        return repository.get(query, operation: operation)
    }
    
    public func getAll(_ query: Query, operation: Harmony.Operation) -> Future<[T]> {
        getAllCalls.append((query, operation))
        return repository.getAll(query, operation: operation)
    }
    
    public private(set) var putCalls: [(value: T?, query: Query, operation: Harmony.Operation)] = []
    public private(set) var putAllCalls: [(array: [T], query: Query, operation: Harmony.Operation)] = []
    
    public func put(_ value: T?, in query: Query, operation: Harmony.Operation) -> Future<T> {
        putCalls.append((value, query, operation))
        return repository.put(value, in: query, operation: operation)
    }
    
    public func putAll(_ array: [T], in query: Query, operation: Harmony.Operation) -> Future<[T]> {
        putAllCalls.append((array, query, operation))
        return repository.putAll(array, in: query, operation: operation)
    }
    
    public private(set) var deleteCalls: [(query: Query, operation: Harmony.Operation)] = []
    public private(set) var deleteAllCalls: [(query: Query, operation: Harmony.Operation)] = []
    
    public func delete(_ query: Query, operation: Harmony.Operation) -> Future<Void> {
        deleteCalls.append((query, operation))
        return repository.delete(query, operation: operation)
    }
    
    public func deleteAll(_ query: Query, operation: Harmony.Operation) -> Future<Void> {
        deleteAllCalls.append((query, operation))
        return repository.deleteAll(query, operation: operation)
    }
}
