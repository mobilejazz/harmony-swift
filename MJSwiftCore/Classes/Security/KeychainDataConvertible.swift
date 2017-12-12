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

public extension Keychain {
    /// Custom getter for DataConvertible conforming types.
    ///
    /// - Parameter key: The key.
    /// - Returns: The DataConvertible conforming value stored in the Keychain or nil.
    public func get<T>(_ key: String) -> T? where T: DataConvertible {
        guard let data : Data = get(key) else {
            return nil
        }
        return T(data:data)
    }
    
    /// Custom setter for DataConvertible conforming types.
    ///
    /// - Parameters:
    ///   - value: The DataConvertible conforming value.
    ///   - key: The key.
    /// - Returns: The operation result.
    @discardableResult
    public func set<T>(_ value: T, forKey key: String) -> Result where T: DataConvertible {
        return set(value.data, forKey: key)
    }
}
