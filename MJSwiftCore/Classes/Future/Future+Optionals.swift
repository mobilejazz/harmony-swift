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

extension FutureError {
    /// - nilValue: The optional can't be unwraped because it is nil
    public static let nilValue = FutureError(rawValue: "Cannot unwrap because value is nil")
}

public extension Future {
    /// Unwrapes a future of an optional type, returning a future of a non-optional type
    public func unwrap<K>() -> Future<K> where T == K? {
        return flatMap { value in
            guard let value = value else {
                return Future<K>(FutureError.nilValue)
            }
            return Future<K>(value)
        }
    }
    
    public func optional() -> Future<T?> {
        return self.map { value -> T? in
            return value
        }
    }
    
    /// Performs a map of an optional future when the value is defined
    public func unwrappedMap<K,P>(_ closure: @escaping (K) -> P) -> Future<P?> where T == K? {
        return flatMap { value in
            guard let value = value else {
                return Future<P?>(nil)
            }
            return Future<P?>(closure(value))
        }
    }
}
