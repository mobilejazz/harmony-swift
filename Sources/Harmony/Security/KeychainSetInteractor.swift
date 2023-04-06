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
/// Keychain set interactor
///
@available(*, deprecated, message: "Use the KeychainDataSource and Repository pattern instead.")
public class KeychainSetInteractor {
    private let executor: Executor
    private let keychain: KeychainService
    private let key: String

    /// Default initializer
    ///
    /// - Parameters:
    ///   - executor: The executor to run the interactor
    ///   - keychain: The keychain instance
    ///   - key: The key to access the user defaults
    public init(_ executor: Executor, _ keychain: KeychainService, _ key: String) {
        self.executor = executor
        self.keychain = keychain
        self.key = key
    }

    /// Convenience initializer.
    /// This initializer uses a shared executor on all KeychainSetInteractor instances and the default service of Keychain().
    ///
    /// - Parameter key: The key to access the user defaults
    public convenience init(_ key: String) {
        self.init(defaultExecutor, KeychainService(), key)
    }

    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute<T>(_ value: T) -> Future<Bool> where T: Encodable {
        return executor.submit { resolver in
            let result = self.keychain.set(value, forKey: self.key)
            switch result {
            case .success:
                resolver.set(true)
            case .failed(let status):
                resolver.set(CoreError.OSStatusFailure(status, "Keychain failed to set value for key \(self.key) (OSStatus \(status))"))
            }
        }
    }
}
