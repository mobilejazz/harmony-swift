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
    public func map<K>(_ transform: @escaping (T) -> K) -> Future<K> {
        return Future<K>(reactive: reactive) { resolver in
            resolve(success: {value in
                resolver.set(transform(value))
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
    
    /// Mappes the error and return a new future with the error mapped
    public func mapError(_ transform: @escaping (Error) -> Error) -> Future<T> {
        return Future(reactive: reactive) { resolver in
            resolve(success: {value in
                resolver.set(value)
            }, failure: { error in
                resolver.set(transform(error))
            })
        }
    }
    
    /// Intercepts the value if success and returns a new future of a mapped type to be chained
    public func flatMap<K>(_ closure: @escaping (T) -> Future<K>) -> Future<K> {
        return Future<K>(reactive: reactive) { resolver in
            resolve(success: {value in
                resolver.set(closure(value))
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
    
    /// Intercepts the error (if available) and returns a new future of type T
    public func recover(_ closure: @escaping (Error) -> Future<T>) -> Future<T> {
        return Future(reactive: reactive) { resolver in
            resolve(success: {value in
                resolver.set(value)
            }, failure: { error in
                resolver.set(closure(error))
            })
        }
    }
    
    /// Performs the closure after the then block is called.
    @discardableResult
    public func onCompletion(_ closure: @escaping () -> Void) -> Future<T> {
        return Future(reactive: reactive) { resolver in
            resolve(success: {value in
                closure()
                resolver.set(value)
            }, failure: { error in
                closure()
                resolver.set(error)
            })
        }
    }
    
    /// Filters the value and allows to exchange it for a thrown error
    public func filter(_ closure: @escaping (T) throws -> Void) -> Future<T> {
        return Future(reactive: reactive) { resolver in
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
