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

///  Object invalidation strategy data source.
public protocol VastraInvalidationStrategyDataSource  {
    func isObjectInvalid() -> Bool
}

/// Object invalidation strategy
///
/// The strategy implements the following approach:
///
/// - If the object is invalid, returns .Invalid
/// - Otherwise returns .Unknown
public class VastraInvalidationStrategy : VastraStrategy {
    
    public func isObjectValid<T>(_ object: T) -> VastraStrategyResult {
        if (object as! VastraInvalidationStrategyDataSource).isObjectInvalid() {
            return .invalid
        }
        return .unknown
    }
}
