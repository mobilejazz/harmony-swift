//
// Copyright 2018 Mobile Jazz SL
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

/// SlowOperation: Data processing will only use the "slow data source".
public class SlowOperation : Operation { public init () { } }

/// SlowSyncOperation: Data processing will use the "slow data source" and then sync result with the "fast data source" if needed.
public class SlowSyncOperation : Operation { public init () { } }

/// FastOperation: Data processing will only use the "fast data source".
public class FastOperation : Operation { public init () { } }

/// FastSyncOperation: Data processing will use the "fast data source" and sync with the "slow data source" if needed.
public class FastSyncOperation : Operation { public init () { } }

///
/// Repository containing two data sources: a fast-access data source and a slow-access data source.
///
/// Using the `SlowOperation`, `SlowSyncOperation`, `FastOperation` and `FastSyncOperation`, the end user can access the fast or slow data source.
/// A typical example of usage is using this repository to alternate between a network-based data source (slow data source) and a local cache storage data source (fast data source).
///
public class FastSlowRepository<S,F,T> : GetRepository, PutRepository, DeleteRepository where S:GetDataSource, S:PutDataSource, S:DeleteDataSource, F:GetDataSource, F:PutDataSource, F:DeleteDataSource, S.T == T, F.T == T {
    
    private let slow: S
    private let fast: F
    
    public init(slow: S, fast: F) {
        self.slow = slow
        self.fast = fast
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case is SlowOperation:
            return slow.get(query)
        case is FastOperation:
            return fast.get(query)
        case is SlowSyncOperation:
            return slow.get(query).flatMap { entity in
                return self.fast.put(entity, in: query)
            }
        case is FastSyncOperation:
            return fast.get(query).recover { error in
                switch error {
                case is CoreError.NotValid, is CoreError.NotFound:
                    return self.get(query, operation: SlowSyncOperation())
                default:
                    return Future(error)
                }
            }
        default:
            operation.fatalError(.get, self)
        }
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case is SlowOperation:
            return slow.getAll(query)
        case is FastOperation:
            return fast.getAll(query)
        case is SlowSyncOperation:
            return slow.getAll(query).flatMap { entities in
                return self.fast.putAll(entities, in: query)
            }
        case is FastSyncOperation:
            return fast.getAll(query).recover { error in
                switch error {
                case is CoreError.NotValid, is CoreError.NotFound:
                    return self.getAll(query, operation: SlowSyncOperation())
                default:
                    return Future(error)
                }
            }
        default:
            operation.fatalError(.getAll, self)
        }
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case is SlowOperation:
            return slow.put(value, in: query)
        case is FastOperation:
            return fast.put(value, in: query)
        case is SlowSyncOperation:
            return slow.put(value, in: query).flatMap { value in
                return self.fast.put(value, in: query)
            }
        case is FastSyncOperation:
            return fast.put(value, in: query).flatMap { value in
                return self.slow.put(value, in: query)
            }
        default:
            operation.fatalError(.put, self)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case is SlowOperation:
            return slow.putAll(array, in: query)
        case is FastOperation:
            return fast.putAll(array, in: query)
        case is SlowSyncOperation:
            return slow.putAll(array, in: query).flatMap { array in
                return self.fast.putAll(array, in: query)
            }
        case is FastSyncOperation:
            return fast.putAll(array, in: query).flatMap { array in
                return self.slow.putAll(array, in: query)
            }
        default:
            operation.fatalError(.putAll, self)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case is SlowOperation:
            return slow.delete(query)
        case is FastOperation:
            return fast.delete(query)
        case is SlowSyncOperation:
            return slow.delete(query).flatMap {
                return self.fast.delete(query)
            }
        case is FastSyncOperation:
            return fast.delete(query).flatMap {
                return self.slow.delete(query)
            }
        default:
            operation.fatalError(.delete, self)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case is SlowOperation:
            return slow.deleteAll(query)
        case is FastOperation:
            return fast.deleteAll(query)
        case is SlowSyncOperation:
            return slow.deleteAll(query).flatMap {
                return self.fast.deleteAll(query)
            }
        case is FastSyncOperation:
            return fast.deleteAll(query).flatMap {
                return self.slow.deleteAll(query)
            }
        default:
            operation.fatalError(.deleteAll, self)
        }
    }
}
