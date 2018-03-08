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

private let defaultExecutor = DispatchQueueExecutor()

///
/// Keychain get interactor
///
public class KeychainGetInteractor <T:DataConvertible> {
    
    /// Custom interactor errors
    public enum CustomError: Error {
        /// Value was not found for the given key
        case notFound
        var localizedDescription: String {
            return "No found keychain data for the given key"
        }
    }
    
    private let executor : Executor
    private let keychain : Keychain
    private let key : String
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - executor: The executor to run the interactor
    ///   - keychain: The keychain instance
    ///   - key: The key to access the user defaults
    public init(_ executor: Executor, _ keychain: Keychain, _ key : String) {
        self.executor = executor
        self.keychain = keychain
        self.key = key
    }
    
    /// Convenience initializer.
    /// This initializer uses a shared executor on all KeychainGetInteractor instances and the default service of Keychain().
    ///
    /// - Parameter key: The key to access the user defaults
    public convenience init(_ key : String) {
        self.init(defaultExecutor, Keychain(), key)
    }
    
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            if let result : T = self.keychain.get(self.key) {
                future.set(result)
            } else {
                future.set(CustomError.notFound)
            }
        }
    }
}
