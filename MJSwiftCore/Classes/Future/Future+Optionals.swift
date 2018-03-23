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
    /// Custom error for unwrapping
    public enum UnwrapError : Error {
        /// Unwrap couldn't be done because value was nil
        case nilValue
        public var localizedDescription: String {
            return "Cannot unwrap because value is nil"
        }
    }
    
    /// Unwrapes a future of an optional type, returning a future of a non-optional type
    public func unwrap<K>() -> Future<K> where T == K? {
        return flatMap { value in
            guard let value = value else {
                return Future<K>(UnwrapError.nilValue)
            }
            return Future<K>(value)
        }
    }
    
    public func optional() -> Future<T?> {
        return self.map { value -> T? in
            return value
        }
    }
}
