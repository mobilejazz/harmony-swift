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
/// Generic interactor to set values to the UserDefaults
///
@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
public class UserDefaultsSetInteractor<T> {
    
    private let executor : Executor
    private let userDefaults : UserDefaults
    private let key : String
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - executor: The executor to run the interactor
    ///   - userDefaults: The user defaults instance
    ///   - key: The key to access the user defaults
    public init(_ executor: Executor, _ userDefaults: UserDefaults, _ key : String) {
        self.executor = executor
        self.userDefaults = userDefaults
        self.key = key
    }
    
    /// Convenience initializer.
    /// This initializer uses a shared executor on all UserDefaultsSetInteractor<T> instances and the UserDefaults.standard.
    ///
    /// - Parameter key: The key to access the user defaults
    public convenience init(_ key : String) {
        self.init(defaultExecutor, UserDefaults.standard, key)
    }
    
    private func _execute(_ value: T?) -> Future<Void> {
        return executor.submit { future in
            if let value = value {
                self.userDefaults.set(value, forKey: self.key)
            } else {
                self.userDefaults.removeObject(forKey: self.key)
            }
            self.userDefaults.synchronize()
            future.set()
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [String : Any] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == Any {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [Any] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == Data {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [Data] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == String {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [String] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == NSNumber {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [NSNumber] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == Date {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [Date] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == Float {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [Float] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == Double {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [Double] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == Int {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [Int] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == Bool {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [Bool] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == URL {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsSetInteractor where T == [URL] {
    /// Main execution method.
    /// Pass nil to remove the value from the user defaults.
    ///
    /// - Returns: A future for the success result or error
    public func execute(_ value: T?) -> Future<Void> {
        return _execute(value)
    }
}
