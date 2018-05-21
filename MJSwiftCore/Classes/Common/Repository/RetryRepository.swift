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
    
    /// Retry action
    ///
    /// - retry: Retry if counter is greater than zero
    /// - fail: Fail the operation
    public enum Action {
        case retry
        case fail
    }
    
    /// The amount of retries. If zero, the operation won't retry
    public let count : Int
    /// A closure defining the retry strategy.
    public let closure : (Error) -> Action
    /// The operation forwarded to the repository
    public let operation : Operation
    
    /// Main initializer
    ///
    /// - Parameters_
    ///   - operation: The operation that will be forwarded to the nested repository
    ///   - count: The retry counter. Default value is 1 (one retry)
    ///   - closure: The inspection closure. Use this closure to filter incoming errors and define a retry policy. Default value returns `.retry`.
    public init(_ operation: Operation , _ count: Int = 1, _ closure: @escaping (Error) -> Action = { _ in return .retry }) {
        self.operation = operation
        self.count = count
        self.closure = closure
    }
    
    /// Creates a new retry operation with the counter decremented by one.
    ///
    /// - Returns: A new retry operation
    public func retry() -> RetryOperation {
        return RetryOperation(operation, count-1, closure)
    }
}

///
/// Repository adding a retry logic over an existing repository when an error happens
///
public class RetryRepository<T> : Repository<T> {
    
    /// The nested repository
    private let repository : Repository<T>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    public init(_ repository: Repository<T>) {
        self.repository = repository
    }
    
    public override func get(_ query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.get(query, operation: retryOp.operation).recover { error in
                if retryOp.closure(error) == .retry && retryOp.count > 0 {
                    return self.get(query, operation: retryOp.retry())
                } else {
                    return Future(error)
                }
            }
        default:
            return super.get(query, operation: operation)
        }
    }
    
    public override func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.getAll(query, operation: retryOp.operation).recover { error in
                if retryOp.closure(error) == .retry && retryOp.count > 0 {
                    return self.getAll(query, operation: retryOp.retry())
                } else {
                    return Future(error)
                }
            }
        default:
            return super.getAll(query, operation: operation)
        }
    }
    
    @discardableResult
    public override func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.put(value, in: query, operation: retryOp.operation).recover { error in
                if retryOp.closure(error) == .retry && retryOp.count > 0 {
                    return self.put(value, in: query, operation: retryOp.retry())
                } else {
                    return Future(error)
                }
            }
        default:
            return super.put(value, in: query, operation: operation)
        }
    }
    
    @discardableResult
    public override func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.putAll(array, in: query, operation: retryOp.operation).recover { error in
                if retryOp.closure(error) == .retry && retryOp.count > 0 {
                    return self.putAll(array, in: query, operation: retryOp.retry())
                } else {
                    return Future(error)
                }
            }
        default:
            return super.putAll(array, in: query, operation: operation)
        }
    }
    
    @discardableResult
    public override func delete(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.delete(query, operation: retryOp.operation).recover { error in
                if retryOp.closure(error) == .retry && retryOp.count > 0 {
                    return self.delete(query, operation: retryOp.retry())
                } else {
                    return Future(error)
                }
            }
        default:
            return super.delete(query, operation: operation)
        }
    }
    
    @discardableResult
    public override func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case let retryOp as RetryOperation:
            return repository.deleteAll(query, operation: retryOp.operation).recover { error in
                if retryOp.closure(error) == .retry && retryOp.count > 0 {
                    return self.deleteAll(query, operation: retryOp.retry())
                } else {
                    return Future(error)
                }
            }
        default:
            return super.deleteAll(query, operation: operation)
        }
    }
}
