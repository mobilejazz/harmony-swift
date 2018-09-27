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
        
    /// Map the value and return a new observable with the value mapped
    public func map<K>(_ executor: Executor = DirectExecutor(), _ transform: @escaping (T) throws -> K) -> Observable<K> {
        return Observable<K>(parent: self) { resolver in
            resolve(success: { value in
                executor.submit {
                    do { resolver.set(try transform(value)) }
                    catch (let error) { resolver.set(error) }
                }
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
    
    /// Mappes the error and return a new observable with the error mapped
    public func mapError(_ executor: Executor = DirectExecutor(), _ transform: @escaping (Error) -> Error) -> Observable<T> {
        return Observable(parent: self) { resolver in
            resolve(success: {value in
                resolver.set(value)
            }, failure: { error in
                executor.submit {
                    resolver.set(transform(error))
                }
            })
        }
    }
    
    /// Intercepts the value if success and returns a new observable of a mapped type to be chained
    public func flatMap<K>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (T) throws -> Observable<K>) -> Observable<K> {
        return Observable<K>(parent: self) { resolver in
            resolve(success: {value in
                executor.submit {
                    do { resolver.set(try closure(value)) }
                    catch (let error) { resolver.set(error) }
                }
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
    
    /// Replaces the current observable value with the new future.
    /// Note: the observable is chained only if the current is resolved without error.
    ///
    /// - Parameter future: The chained observable
    /// - Returns: The incoming observable chained to the current one
    public func chain<K>(_ future: Observable<K>) -> Observable<K> {
        return flatMap { value in
            return future
        }
    }
    
    /// Intercepts the error (if available) and returns a new observable of type T
    public func recover(_ executor: Executor = DirectExecutor(), _ closure: @escaping (Error) throws -> Observable<T>) -> Observable<T> {
        return Observable(parent: self) { resolver in
            resolve(success: {value in
                resolver.set(value)
            }, failure: { error in
                executor.submit {
                    do { resolver.set(try closure(error)) }
                    catch (let error) { resolver.set(error) }
                }
            })
        }
    }
    
    /// Performs the closure after the then block is called.
    @discardableResult
    public func onCompletion(_ executor: Executor = DirectExecutor(), _ closure: @escaping () -> Void) -> Observable<T> {
        return Observable(parent: self) { resolver in
            resolve(success: {value in
                executor.submit { closure() }
                resolver.set(value)
            }, failure: { error in
                executor.submit { closure() }
                resolver.set(error)
            })
        }
    }
    
    /// Filters the value and allows to exchange it for a thrown error
    public func filter(_ executor: Executor = DirectExecutor(), _ closure: @escaping (T) throws -> Void) -> Observable<T> {
        return Observable(parent: self) { resolver in
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
                resolver.set(error)
            })
        }
    }
}
