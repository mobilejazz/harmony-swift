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

import MJCocoaCore

/// Catches exception raised by MJFutures, converts them to NSErrors and finally throws them.
///
/// - Parameter closure: The closure
/// - Returns: The returned value from the closure
/// - Throws: The error included in an exception raised by a MJFuture when using the .value() method
func `catchAndThrow`<K>(_ closure: @escaping () -> K?) throws -> K? {
    var value : K? = nil
    var error : Error? = nil
    ObjC.try({
        value = closure()
    }, catch: { exception in
        error = exception.userInfo?[MJFutureErrorKey] as? NSError
        if error == nil {
            // if no error found, the exception was not initiated by a MJFuture.
            // Therefore, lets raise it again.
            exception.raise()
        }
    })
    if let error = error {
        throw error
    }
    return value
}
