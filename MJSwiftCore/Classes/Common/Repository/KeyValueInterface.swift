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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

///
/// Abstract definition of a key value interface
///
open class KeyValueInterface <T> {
    /// Getter by key.
    ///
    /// - Parameter key: The key
    /// - Returns: The value
    open func get(_ key: String) -> T? {
        fatalError("This method is unimplemented")
    }
    
    /// Array getter by key.
    ///
    /// - Parameter key: The key
    /// - Returns: The value
    open func getAll(_ key: String) -> [T]? {
        fatalError("This method is unimplemented")
    }
    
    /// Setter by key.
    ///
    /// - Parameters:
    ///   - value: The value
    ///   - key: The key
    /// - Returns: True if success, false if failure
    @discardableResult
    open func set(_ value: T, forKey key: String) -> Bool {
        fatalError("This method is unimplemented")
    }
    
    /// Array setter by key.
    ///
    /// - Parameters:
    ///   - array: The array
    ///   - key: The key
    /// - Returns: True if success, false if failure
    @discardableResult
    open func setAll(_ array: [T], forKey key: String) -> Bool  {
        fatalError("This method is unimplemented")
    }
    
    /// Delete a value or an array by key.
    ///
    /// - Parameter key: The key
    /// - Returns: True if success, false if failure
    @discardableResult
    open func delete(_ key: String) -> Bool  {
        fatalError("This method is unimplemented")
    }
}
