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

public extension Observable {
        
    /// Maps the value and return a new observable with the value mapped
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - transform: The map closure
    /// - Returns: A value-mapped chained observable
    func map<K>(_ executor: Executor = DirectExecutor(), _ transform: @escaping (T) throws -> K) -> Observable<K> {
        return Observable<K>(parent: self) { resolver in
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
    
    /// Maps the error and return a new observable with the error mapped
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - transform: The map closure
    /// - Returns: A error-mapped chained future
    func mapError(_ executor: Executor = DirectExecutor(), _ transform: @escaping (Error) -> Error) -> Observable<T> {
        return Observable(parent: self) { resolver in
            resolve(success: { value in
                executor.submit { resolver.set(value) }
            }, failure: { error in
                executor.submit { resolver.set(transform(error)) }
            })
        }
    }
    
    /// Intercepts the value if success and returns a new observable of a mapped type to be chained
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The flatmap closure
    /// - Returns: A chained observable
    func flatMap<K>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (T) throws -> Observable<K>) -> Observable<K> {
        return Observable<K>(parent: self) { resolver in
            resolve(success: { value in
                executor.submit {
                    do { resolver.set(try closure(value)) }
                    catch (let error) { resolver.set(error) }
                }
            }, failure: { error in
                executor.submit { resolver.set(error) }
            })
        }
    }
    
    /// Replaces the current observable value with the new future.
    /// Note: the observable is chained only if the current is resolved without error.
    ///
    /// - Parameter observable: The chained observable
    /// - Returns: The incoming observable chained to the current one
    func chain<K>(_ observable: Observable<K>) -> Observable<K> {
        return flatMap { value in
            return observable
        }
    }
    
    /// Intercepts the error (if available) and returns a new observable of type T
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The recover closure
    /// - Returns: A chained observable
    func recover(_ executor: Executor = DirectExecutor(), _ closure: @escaping (Error) throws -> Observable<T>) -> Observable<T> {
        return Observable(parent: self) { resolver in
            resolve(success: { value in
                executor.submit { resolver.set(value) }
            }, failure: { error in
                executor.submit {
                    do { resolver.set(try closure(error)) }
                    catch (let error) { resolver.set(error) }
                }
            })
        }
    }
    
    /// Intercepts the error (if available) and returns a new observable of type T
    ///
    /// - Parameters:
    ///    - error: The error type to recover only.
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The recover closure
    /// - Returns: A chained observable
    func recover<E:Error>(if errorType: E.Type, _ executor: Executor = DirectExecutor(), _ closure: @escaping (E) throws -> Observable<T>) -> Observable<T> {
        return Observable(parent: self) { resolver in
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
    
    /// Notifies completion of the observable in both success or failure state.
    ///
    /// - Parameters:
    ///    - executor: An optional executor to execute the closure.
    ///    - closure: The completion closure
    /// - Returns: A chained observable
    @discardableResult
    func onCompletion(_ executor: Executor = DirectExecutor(), _ closure: @escaping () -> Void) -> Observable<T> {
        return Observable(parent: self) { resolver in
            resolve(success: { value in
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
    /// - Returns: A chained observable
    func filter(_ executor: Executor = DirectExecutor(), _ closure: @escaping (T) throws -> Void) -> Observable<T> {
        return Observable(parent: self) { resolver in
            resolve(success: { value in
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
