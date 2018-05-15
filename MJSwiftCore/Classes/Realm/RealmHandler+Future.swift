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
import RealmSwift

public extension RealmHandler {
    
    /// Future friendly read method.
    ///
    /// - Parameter closure: A closure providing a realm instance to execute read queries. Return must be the result of the query.
    /// - Returns: A future that will contain the result of the query, if available.
    public func read<T>(_ closure: (Realm) throws -> T?) -> Future<T> {
        return Future<T>() { resolver in
            do {
                try read { realm in
                    if let value = try closure(realm) {
                        resolver.set(value)
                    } else {
                        resolver.set(CoreError.notFound)
                    }
                }
            } catch let error {
                resolver.set(error)
            }
        }
    }
    
    /// Future friendly write method.
    ///
    /// - Parameter closure: A closure providing a realm instance to execute write queries. Return must be the result of the query.
    /// - Returns: A future that will contain the result of the query, if available.
    public func write<T>(_ closure: (Realm) throws -> T?) -> Future<T> {
        return Future<T>() { future in
            do {
                try write { realm in
                    if let value = try closure(realm) {
                        future.set(value)
                    } else {
                        future.set(CoreError.notFound)
                    }
                }
            } catch let error {
                future.set(error)
            }
        }
    }
}
