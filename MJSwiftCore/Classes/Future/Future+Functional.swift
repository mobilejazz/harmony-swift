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
        
    /// Map the value and return a new future with the value mapped
    ///
    /// - Parameter transform: The map closure
    /// - Returns: A value-mapped chained future
    public func map<K>(_ transform: @escaping (T) throws -> K) -> Future<K> {
        return Future<K>() { resolver in
            resolve(success: { value in
                do { resolver.set(try transform(value)) }
                catch (let error) { resolver.set(error) }
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
    
    /// Mappes the error and return a new future with the error mapped
    ///
    /// - Parameter transform: The map closure
    /// - Returns: A error-mapped chained future
    public func mapError(_ transform: @escaping (Error) -> Error) -> Future<T> {
        return Future() { resolver in
            resolve(success: {value in
                resolver.set(value)
            }, failure: { error in
                resolver.set(transform(error))
            })
        }
    }
    
    /// Intercepts the value if success and returns a new future of a mapped type to be chained
    ///
    /// - Parameter closure: The flatmap closure
    /// - Returns: A chained future
    public func flatMap<K>(_ closure: @escaping (T) throws -> Future<K>) -> Future<K> {
        return Future<K>() { resolver in
            resolve(success: {value in
                do { resolver.set(try closure(value)) }
                catch (let error) { resolver.set(error) }
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
    
    /// Replaces the current future value with the new future.
    /// Note: the future is chained only if the current is resolved without error.
    ///
    /// - Parameter future: The chained future
    /// - Returns: The incoming future chained to the current one
    public func chain<K>(_ future: Future<K>) -> Future<K> {
        return flatMap { value in
            return future
        }
    }
    
    /// Intercepts the error (if available) and returns a new future of type T
    ///
    /// - Parameter closure: The recover closure
    /// - Returns: A chained future
    public func recover(_ closure: @escaping (Error) throws -> Future<T>) -> Future<T> {
        return Future() { resolver in
            resolve(success: {value in
                resolver.set(value)
            }, failure: { error in
                do {
                    let future = try closure(error)
                    resolver.set(future)
                } catch (let error) {
                    resolver.set(error)
                }
            })
        }
    }
    
    /// Notifies completion of the future in both success or failure state.
    ///
    /// - Parameter closure: The completion closure
    /// - Returns: A chained future
    @discardableResult
    public func onCompletion(_ closure: @escaping () -> Void) -> Future<T> {
        return Future() { resolver in
            resolve(success: {value in
                closure()
                resolver.set(value)
            }, failure: { error in
                closure()
                resolver.set(error)
            })
        }
    }
    
    /// Filters the value and allows to exchange it by a thrown error
    ///
    /// - Parameter closure: The filter closure. Throw an error to replace it's value for an error.
    /// - Returns: A chained future
    public func filter(_ closure: @escaping (T) throws -> Void) -> Future<T> {
        return Future() { resolver in
            resolve(success: {value in
                do {
                    try closure(value)
                    resolver.set(value)
                } catch (let error) {
                    resolver.set(error)
                }
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
}
