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

///
/// The retry operation
///
public class RetryOperation : Operation {
    
    /// The amount of retries. If zero, the operation won't retry
    public let count : Int
    /// A closure defining the retry strategy.
    public let retryIf : (Error) -> Bool
    /// The operation forwarded to the repository
    public let operation : Operation
    
    /// Main initializer
    ///
    /// - Parameters_
    ///   - operation: The operation that will be forwarded to the nested repository
    ///   - count: The retry counter. Default value is 1 (one retry)
    ///   - retryIf: A closure to evaluate each retry error. Return true to allow a retry, false otherwise. Default closure returns true.
    public init(_ operation: Operation , _ count: Int = 1, _ retryIf: @escaping (Error) -> Bool = { _ in true }) {
        self.operation = operation
        self.count = count
        self.retryIf = retryIf
    }
    
    /// Validates if the current operation is enabled to retry
    ///
    /// - Parameter error: The incoming error
    /// - Returns: True if can retry, false otherwise.
    public func canRetry(_ error: Error) -> Bool {
        return count > 0 && retryIf(error)
    }
    
    /// Creates a new retry operation with the counter decremented by one.
    ///
    /// - Returns: A new retry operation
    public func next() -> RetryOperation {
        return RetryOperation(operation, count-1, retryIf)
    }
}

///
/// Repository adding a retry logic over an existing repository when an error happens.
/// Incoming operations of a different type as RetryOperation will be forwarded to the contained repository.
///
public class RetryRepository <R: Repository,T> : Repository where T == R.T {
        
    /// The nested repository
    private let repository : R
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    public init(_ repository: R) {
        self.repository = repository
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.get(query, operation: retryOp.operation).recover { error in
                if retryOp.canRetry(error) {
                    return self.get(query, operation: retryOp.next())
                } else {
                    throw error
                }
            }
        default:
            return repository.get(query, operation: operation)
        }
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.getAll(query, operation: retryOp.operation).recover { error in
                if retryOp.canRetry(error) {
                    return self.getAll(query, operation: retryOp.next())
                } else {
                    throw error
                }
            }
        default:
            return repository.getAll(query, operation: operation)
        }
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.put(value, in: query, operation: retryOp.operation).recover { error in
                if retryOp.canRetry(error) {
                    return self.put(value, in: query, operation: retryOp.next())
                } else {
                    throw error
                }
            }
        default:
            return repository.put(value, in: query, operation: operation)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.putAll(array, in: query, operation: retryOp.operation).recover { error in
                if retryOp.canRetry(error) {
                    return self.putAll(array, in: query, operation: retryOp.next())
                } else {
                    throw error
                }
            }
        default:
            return repository.putAll(array, in: query, operation: operation)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.delete(query, operation: retryOp.operation).recover { error in
                if retryOp.canRetry(error) {
                    return self.delete(query, operation: retryOp.next())
                } else {
                    throw error
                }
            }
        default:
            return repository.delete(query, operation: operation)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.deleteAll(query, operation: retryOp.operation).recover { error in
                if retryOp.canRetry(error) {
                    return self.deleteAll(query, operation: retryOp.next())
                } else {
                    throw error
                }
            }
        default:
            return repository.deleteAll(query, operation: operation)
        }
    }
}
