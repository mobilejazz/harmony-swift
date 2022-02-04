//
// Copyright 2019 Mobile Jazz SL
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

/// Object validation interface
public protocol ObjectValidation {
    /// Validates an object
    func isObjectValid<T>(_ object: T) -> Bool
    
    /// Validates an array of objects
    func isArrayValid<T>(_ objects: [T]) -> Bool
}

public extension ObjectValidation {
    
    /// Validator method for arrays
    ///
    /// The validation process iterates over the array and is considered valid if all objects are valid.
    /// Note that:
    ///   - An empty array is considered invalid
    ///   - A nil instance is considered invalid
    ///
    /// - Parameter object: The object to validate.
    /// - Returns: true if valid, false otherwise.
    func isArrayValid<T>(_ objects: [T]) -> Bool {
        if objects.isEmpty {
            return false
        }
        for object in objects {
            if !isObjectValid(object) {
                return false
            }
        }
        return true
    }
}

///
/// Default implementation returns always true (all objects are valid)
///
public class DefaultObjectValidation : ObjectValidation {
    public init() {}
    public func isObjectValid<T>(_ object: T) -> Bool {
        return true
    }
}
