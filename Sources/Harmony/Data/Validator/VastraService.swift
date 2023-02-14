//
// Copyright 2017 Mobile Jazz SL
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

/// A validation service contains multiple strategies.
/// The validation service will try to validate an object with each strategy by order.
///
/// The first strategy that validates or invalidates the object will define the validity of the object.
///
/// If any strategy succeeds to validate or invalidate the object, the validation will fail and the object will be considered as invalid.
public class VastraService: ObjectValidation {
    /// Array of validation strategies.
    public let strategies: [VastraStrategy]

    /// Main initializer
    ///
    /// - Parameter strategies: Array of validation strategies
    public init(_ strategies: [VastraStrategy]) {
        self.strategies = strategies
    }

    /// If none of the strategies can resolve the state, this is the object validation state returned
    public var defaultValidationState = false

    /// Main validator method.
    ///
    /// The validation process iterates over the strategies array in order.
    /// The first strategy that returns Valid or Invalid will make this method return true or false.
    /// If all strategies are consumed and none decided, default return value is false.
    ///
    /// - Parameter object: The object to validate.
    /// - Returns: true if valid, false otherwise.
    public func isObjectValid<T>(_ object: T) -> Bool {
        for strategy in strategies {
            let result = strategy.isObjectValid(object)
            if result == .valid {
                return true
            } else if result == .invalid {
                return false
            }
        }
        return defaultValidationState
    }
}
