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

/// Specifies the validity of an object by an strategy
///
/// - Unknown: Strategy cannot decide if valid or invalid
/// - Valid: Strategy decides the object is valid
/// - Invalid: Strategy decides the object is invalid
public enum VastraStrategyResult {
    case Unknown
    case Valid
    case Invalid
}

///
/// Superclass strategy. Sublcasses will define custom strategies.
///
public protocol VastraStrategy {
    
    /// Strategy validation method.
    ///
    /// - Parameter object: The object to test
    /// - Returns: The validation strategy result
    func isObjectValid<T>(_ object: T) -> VastraStrategyResult
}
