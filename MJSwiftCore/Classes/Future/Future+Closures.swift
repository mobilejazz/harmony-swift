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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implOied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


import Foundation


extension Future where T == () -> Void {
    
    /// Executes the closure
    ///
    /// - Returns: A chained future
    @discardableResult
    public func execute() -> Future<T> {
        return then { closure in
            closure()
        }
    }
}

extension Future where T == () -> Int {
    
    /// Executes the closure
    ///
    /// - Returns: A chained future
    @discardableResult
    public func execute() -> Future<Int> {
        return Future<Int> { resolver in
            then { closure in
                resolver.set(closure())
            }
        }
    }
}
