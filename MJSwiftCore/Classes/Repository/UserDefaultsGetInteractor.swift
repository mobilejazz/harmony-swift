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
/// Generic interactor to get values from the UserDefaults
///
@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
public class UserDefaultsGetInteractor<T> {

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
    /// This initializer uses a shared executor on all UserDefaultsGetInteractor<T> instances and the UserDefaults.standard.
    ///
    /// - Parameter key: The key to access the user defaults
    public convenience init(_ key : String) {
        self.init(defaultExecutor, UserDefaults.standard, key)
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == Any {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.object(forKey: self.key) else {
                future.set(value:nil, error:CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value:value, error:nil)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [Any] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.array(forKey: self.key) else {
                future.set(value:nil, error:CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value:value, error:nil)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [String : Any] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.dictionary(forKey: self.key) else {
                future.set(value:nil, error:CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value:value, error:nil)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == Date {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.object(forKey: self.key) else {
                future.set(CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value as! Date)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [Date] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.array(forKey: self.key)
            future.set(value as! T)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == URL {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.url(forKey: self.key) else {
                future.set(CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [URL] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.array(forKey: self.key)
            future.set(value as! T)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == String {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.string(forKey: self.key) else {
                future.set(CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [String] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.stringArray(forKey: self.key) else {
                future.set(CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == Data {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            guard let value = self.userDefaults.data(forKey: self.key) else {
                future.set(CoreError.NotFound("Value not found for key \(self.key)"))
                return
            }
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [Data] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.array(forKey: self.key)
            future.set(value as! T)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == Bool {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.bool(forKey: self.key)
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [Bool] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.array(forKey: self.key)
            future.set(value as! T)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == Int {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.integer(forKey: self.key)
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [Int] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.array(forKey: self.key)
            future.set(value as! T)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == Float {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.float(forKey: self.key)
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [Float] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.array(forKey: self.key)
            future.set(value as! T)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == Double {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.double(forKey: self.key)
            future.set(value)
        }
    }
}

@available(*, deprecated, message: "Use the DeviceStorageDataSource and Repository pattern instead.")
extension UserDefaultsGetInteractor where T == [Double] {
    /// Main execution method
    ///
    /// - Returns: A future for the result value or error
    public func execute() -> Future<T> {
        return executor.submit { future in
            let value = self.userDefaults.array(forKey: self.key)
            future.set(value as! T)
        }
    }
}
