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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implOied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public extension Future {
        
    /// Maps the value and return a new future with the value mapped
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - transform: The map closure
    /// - Returns: A value-mapped chained future
    func map<K>(_ executor: Executor = DirectExecutor(), _ transform: @escaping (T) throws -> K) -> Future<K> {
        return Future<K> { resolver in
            resolve(success: { value in
                executor.submit {
                    do { resolver.set(try transform(value)) }
                    catch (let error) { resolver.set(error) }
                }
            }, failure: { error in
                executor.submit { resolver.set(error) }
            })
        }
    }
    
    /// Maps the error and return a new future with the error mapped
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - transform: The map closure
    /// - Returns: A error-mapped chained future
    func mapError(_ executor: Executor = DirectExecutor(), _ transform: @escaping (Error) -> Error) -> Future<T> {
        return Future { resolver in
            resolve(success: {value in
                executor.submit { resolver.set(value) }
            }, failure: { error in
                executor.submit { resolver.set(transform(error)) }
            })
        }
    }
    
    /// Intercepts the value if success and returns a new future of a mapped type to be chained
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The flatmap closure
    /// - Returns: A chained future
    func flatMap<K>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (T) throws -> Future<K>) -> Future<K> {
        return Future<K> { resolver in
            resolve(success: {value in
                executor.submit {
                    do { resolver.set(try closure(value)) }
                    catch (let error) { resolver.set(error) }
                }
            }, failure: { error in
                executor.submit { resolver.set(error) }
            })
        }
    }
    
    /// Replaces the current future value with the new future.
    /// Note: the future is chained only if the current is resolved without error.
    ///
    /// - Parameter future: The chained future
    /// - Returns: The incoming future chained to the current one
    func chain<K>(_ future: Future<K>) -> Future<K> {
        return flatMap { value in
            return future
        }
    }
    
    /// Intercepts the error (if available) and returns a new future of type T
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The recover closure
    /// - Returns: A chained future
    func recover(_ executor: Executor = DirectExecutor(), _ closure: @escaping (Error) throws -> Future<T>) -> Future<T> {
        return Future { resolver in
            resolve(success: {value in
                executor.submit { resolver.set(value) }
            }, failure: { error in
                executor.submit {
                    do { resolver.set(try closure(error)) }
                    catch (let error) { resolver.set(error) }
                }
            })
        }
    }
    
    /// Intercepts the error (if available) and returns a new future of type T
    ///
    /// - Parameters:
    ///    - error: The error type to recover only.
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The recover closure
    /// - Returns: A chained future
    func recover<E:Error>(if errorType: E.Type, _ executor: Executor = DirectExecutor(), _ closure: @escaping (E) throws -> Future<T>) -> Future<T> {
        return Future { resolver in
            resolve(success: {value in
                executor.submit { resolver.set(value) }
            }, failure: { error in
                executor.submit {
                    switch error {
                    case let error as E:
                        do {
                            resolver.set(try closure(error))
                        } catch let error {
                            resolver.set(error)
                        }
                    default:
                        resolver.set(error)
                    }
                }
            })
        }
    }
    
    /// Notifies completion of the future in both success or failure state.
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The completion closure
    /// - Returns: A chained future
    @discardableResult
    func onCompletion(_ executor: Executor = DirectExecutor(), _ closure: @escaping () -> Void) -> Future<T> {
        return Future { resolver in
            resolve(success: {value in
                executor.submit {
                    closure()
                    resolver.set(value)
                }
            }, failure: { error in
                executor.submit {
                    closure()
                    resolver.set(error)
                }
            })
        }
    }
    
    /// Filters the value and allows to exchange it by a thrown error
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The filter closure. Throw an error to replace it's value for an error.
    /// - Returns: A chained future
    func filter(_ executor: Executor = DirectExecutor(), _ closure: @escaping (T) throws -> Void) -> Future<T> {
        return Future { resolver in
            resolve(success: {value in
                executor.submit {
                    do {
                        try closure(value)
                        resolver.set(value)
                    } catch (let error) {
                        resolver.set(error)
                    }
                }
            }, failure: { error in
                executor.submit { resolver.set(error) }
            })
        }
    }
}
