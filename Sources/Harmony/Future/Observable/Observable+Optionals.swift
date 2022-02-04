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
    
    /// Unwrapes a observable of an optional type, returning a observable of a non-optional type
    ///
    /// - Returns: A chained observable.
    func unwrap<K>() -> Observable<K> where T == K? {
        return flatMap { value in
            guard let value = value else {
                return Observable<K>(NilValueError(), parent: self)
            }
            return Observable<K>(value, parent: self)
        }
    }
    
    /// Converts the non-optional typed observable to an optional typed observable
    ///
    /// - Returns: An optional typed observable
    func optional() -> Observable<T?> {
        return self.map { $0 as T? }
    }
    
    /// Calls the closure when the observable is resolved with a nil value.
    ///
    /// - Parameter closure: The closure that will return a non-nil value.
    /// - Returns: A observable with a non-optional type.
    func fill<K>(_ executor: Executor = DirectExecutor(), _ closure: @escaping () -> K) -> Observable<K>  where T == K? {
        return flatMap(executor) { value in
            guard let value = value else {
                return Observable<K>(closure())
            }
            return Observable<K>(value)
        }
    }
    
    /// Calls the closure when the observable is resolved with a nil value.
    ///
    /// - Parameter closure: The closure that will return a non-optional observable.
    /// - Returns: A observable with a non-optional type.
    func flatFill<K>(_ executor: Executor = DirectExecutor(), _ closure: @escaping () -> Observable<K>) -> Observable<K>  where T == K? {
        return flatMap(executor) { value in
            guard let value = value else {
                return Observable<K>(closure())
            }
            return Observable<K>(value)
        }
    }
    
    /// Performs a map of an optional observable when the value is defined.
    ///
    /// - Returns: A chained observable.
    func unwrappedMap<K,P>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K) -> P) -> Observable<P?> where T == K? {
        return flatMap(executor) { value in
            guard let value = value else {
                return Observable<P?>(nil)
            }
            return Observable<P?>(closure(value))
        }
    }
}
