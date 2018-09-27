///
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

extension Array {
    
    /// Multi-thread map method
    ///
    /// - Parameters:
    ///   - executor: The executor to use on each map
    ///   - transform: The mapping closure
    /// - Returns: An array of mapped elements
    /// - Throws: The first mapping throwed error
    public func map<T>(_ executor : Executor, _ transform : @escaping (Element) throws -> T) throws -> [T] {
        let futures : [Future<T>] = self.map { element in
            let future : Future<T> = executor.submit { resolver in
                resolver.set(try transform(element))
            }
            return future
        }
        return try Future.batch(futures).result.get()
    }
}
