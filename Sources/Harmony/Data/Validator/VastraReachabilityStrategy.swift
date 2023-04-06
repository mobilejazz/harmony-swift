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

/// Reachability interface
public protocol VastraReachability {
    func isReachable() -> Bool
}

/// The strategy implements the following approach:
///
/// - If internet is NOT available: the strategy considers all objects valid (.Valid)
/// - If internet is available: the strategy doesn't decide if the object is valid (.Unknown)
public class VastraReachabilityStrategy: VastraStrategy {
    private let reachability: VastraReachability

    /// Default initializer
    ///
    /// - Parameter reachability: An reachability object
    public init(_ reachability: VastraReachability) {
        self.reachability = reachability
    }

    public func isObjectValid<T>(_ object: T) -> VastraStrategyResult {
        if reachability.isReachable() {
            return .unknown
        } else {
            return .valid
        }
    }
}
