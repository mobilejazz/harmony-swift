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

private struct RetryRule {
    /// The amount of retries. If zero, the operation won't retry
    public let count : Int
    /// A closure defining the retry strategy.
    public let retryIf : (Error) -> Bool
    
    /// Validates if the current operation is enabled to retry
    ///
    /// - Parameter error: The incoming error
    /// - Returns: True if can retry, false otherwise.
    public func canRetry(_ error: Error) -> Bool {
        return count > 0 && retryIf(error)
    }

    /// Creates a new retry rule with the counter decremented by one.
    ///
    /// - Returns: The next retry rule
    public func next() -> RetryRule {
        return RetryRule(count: count-1, retryIf: retryIf)
    }
}

///
/// The retry operation
///
public class RetryOperation : Operation {
    
    /// The retry rule
    private let retryRule : RetryRule
    
    /// The operation forwarded to the repository
    public let operation : Operation
    
    /// Main initializer
    ///
    /// - Parameters_
    ///   - operation: The operation that will be forwarded to the nested repository
    ///   - count: The retry counter. Default value is 1.
    ///   - retryIf: A closure to evaluate each retry error. Return true to allow a retry, false otherwise. Default closure returns true.
    public init(_ operation: Operation , count: Int = 1, retryIf: @escaping (Error) -> Bool = { _ in true }) {
        self.operation = operation
        self.retryRule = RetryRule(count: count, retryIf: retryIf)
    }
    
    fileprivate init(_ operation: Operation, _ retryRule : RetryRule) {
        self.operation = operation
        self.retryRule = retryRule
    }
    
    /// Validates if the current operation is enabled to retry
    ///
    /// - Parameter error: The incoming error
    /// - Returns: True if can retry, false otherwise.
    public func canRetry(_ error: Error) -> Bool {
        return retryRule.canRetry(error)
    }
    
    /// Creates a new retry operation with the counter decremented by one.
    ///
    /// - Returns: A new retry operation
    public func next() -> RetryOperation {
        return RetryOperation(operation, retryRule.next())
    }
}

///
/// Repository adding a retry logic over an existing repository when an error happens.
/// Incoming operations of a different type as RetryOperation will be forwarded to the contained repository.
///
public class RetryRepository <R,T> : GetRepository, PutRepository, DeleteRepository where R:GetRepository, R:PutRepository, R:DeleteRepository, T == R.T {
        
    /// The nested repository
    private let repository : R
    
    /// The default retry rule
    private let retryRule : RetryRule
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    public init(_ repository: R, retryCount: Int = 1, retryIf: @escaping (Error) -> Bool = { _ in true }) {
        self.repository = repository
        self.retryRule = RetryRule(count: retryCount, retryIf: retryIf)
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
            return repository.get(query, operation: RetryOperation(operation, retryRule))
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
            return repository.getAll(query, operation: RetryOperation(operation, retryRule))
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
            return repository.put(value, in: query, operation: RetryOperation(operation, retryRule))
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
            return repository.putAll(array, in: query, operation: RetryOperation(operation, retryRule))
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
            return repository.delete(query, operation: RetryOperation(operation, retryRule))
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
            return repository.deleteAll(query, operation: RetryOperation(operation, retryRule))
        }
    }
}
