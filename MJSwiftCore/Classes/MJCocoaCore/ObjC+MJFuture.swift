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
import MJCocoaCore

extension ObjC {
    /// Private method to wrap a sync access to a MJFuture.value and convert the error exception into a swfit error.
    ///
    /// - Parameter closure: The closure where the future is accessed.
    /// - Throws: The MJFuture error if available.
    private static func `try`(_ closure: @escaping () -> Void) throws {
        var finalError : Error? = nil
        self.try({
            closure()
        }, catch: { exception in
            if let error = exception.userInfo?[MJFutureErrorKey] as? Error {
                finalError = error
            }
        })
        
        if let error = finalError {
            throw error
        }
    }
    
    /// Use this method to extract the value synchronously from a MJFuture.
    ///
    /// - Parameter future: The future to access its value.
    /// - Returns: The future's value.
    /// - Throws: The future's error.
    @discardableResult
    public static func `try`<T>(_ future : MJFuture<T>) throws -> T? {
        var value : T?
        try ObjC.try {
            value = future.value()
        }
        return value
    }
}

