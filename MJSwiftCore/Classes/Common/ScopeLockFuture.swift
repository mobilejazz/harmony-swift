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

public extension ScopeLock {
    /// Syncing method using futures
    ///
    /// - Parameter closure: The sync closure
    /// - Returns: A future contining the result
    func sync<T>(_ closure: () -> T) -> Future<T> {
        return Future<T> { future in
            sync {
                future.set(closure())
            }
        }
    }
    
    /// Syncing method using an async closure
    /// Note the sync will kept active until the future sets its value or error.
    ///
    /// - Parameter closure: The sync closure
    /// - Returns: A future
    func async<T>(_ closure: (Future<T>) -> Void) -> Future<T> {
        let future = Future<T>()
        async { end in
            future.onSet {
                end()
            }
            closure(future)
        }
        return future.toFuture()
    }
}
