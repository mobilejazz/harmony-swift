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


/// Future can't unrwap because value is nil error
public class NilValueError : Error { public init() {} }

public extension Future {
    
    /// Unwrapes a future of an optional type, returning a future of a non-optional type
    ///
    /// - Returns: A chained future.
    func unwrap<K>() -> Future<K> where T == K? {
        return flatMap { value in
            guard let value = value else {
                return Future<K>(NilValueError())
            }
            return Future<K>(value)
        }
    }
    
    /// Converts the non-optional typed future to an optional typed future
    ///
    /// - Returns: An optional typed future
    func optional() -> Future<T?> {
        return self.map { $0 as T? }
    }
    
    /// Calls the closure when the future is resolved with a nil value.
    ///
    /// - Parameter closure: The closure that will return a non-nil value.
    /// - Returns: A future with a non-optional type.
    func fill<K>(_ executor: Executor = DirectExecutor(), _ closure: @escaping () -> K) -> Future<K>  where T == K? {
        return flatMap(executor) { value in
            guard let value = value else {
                return Future<K>(closure())
            }
            return Future<K>(value)
        }
    }
    
    /// Calls the closure when the future is resolved with a nil value.
    ///
    /// - Parameter closure: The closure that will return a non-optional future.
    /// - Returns: A future with a non-optional type.
    func flatFill<K>(_ executor: Executor = DirectExecutor(), _ closure: @escaping () -> Future<K>) -> Future<K>  where T == K? {
        return flatMap(executor) { value in
            guard let value = value else {
                return Future<K>(closure())
            }
            return Future<K>(value)
        }
    }
    
    /// Performs a map of an optional future when the value is defined.
    ///
    /// - Returns: A chained future.
    func unwrappedMap<K,P>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K) -> P) -> Future<P?> where T == K? {
        return flatMap(executor) { value in
            guard let value = value else {
                return Future<P?>(nil)
            }
            return Future<P?>(closure(value))
        }
    }
}
