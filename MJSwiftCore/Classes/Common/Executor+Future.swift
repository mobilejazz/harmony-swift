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

extension Executor {
    
    /// Submits a closure for its execution with a future to be filled.
    ///  Note that the future returned is not the same as the future privded in the closure.
    ///
    /// - Parameter closure: The closure to be executed. The future must be filled.
    /// - Returns: A future wrapping the result.
    @discardableResult public func submit<T>(_ closure: @escaping (Future<T>) -> Void) -> Future<T> {
        return Future() { future in
            self.submit { end in
                future.onSet {
                    end()
                }
                closure(future)
            }
        }.toFuture().onMainQueue() // Creating a new future to avoid a duplicate call to onSet to the same future
    }
}
