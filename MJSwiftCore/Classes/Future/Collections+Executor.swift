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
    
    /// Executor-based map method
    ///
    /// - Parameters:
    ///   - executor: The executor to use on each map
    ///   - transform: The mapping closure
    /// - Returns: An array of mapped elements
    /// - Throws: The first mapping thrown error
    public func map<T>(_ executor : Executor, _ transform : @escaping (Element) throws -> T) rethrows -> [T] {
        let futures : [Future<T>] = self.map { element in
            let future : Future<T> = executor.submit { resolver in
                resolver.set(try transform(element))
            }
            return future
        }
        return try! Future.batch(futures).result.get()
    }
}

extension Set {
    
    /// Executor-based map method
    ///
    /// - Parameters:
    ///   - executor: The executor to use on each map
    ///   - transform: The mapping closure
    /// - Returns: A set of mapped elements
    /// - Throws: The first mapping thrown error
    public func map<T>(_ executor : Executor, _ transform : @escaping (Element) throws -> T) rethrows -> [T] {
        let futures : [Future<T>] = self.map { element in
            let future : Future<T> = executor.submit { resolver in
                resolver.set(try transform(element))
            }
            return future
        }
        return try! Future.batch(futures).result.get()
    }
}

extension Dictionary {
    
    /// Executor-based map method
    ///
    /// - Parameters:
    ///   - executor: The executor to use on each map
    ///   - transform: The mapping closure
    /// - Returns: A dictionary with mapped keys
    /// - Throws: The first mapping thrown error
    public func mapKeys<T:Hashable>(_ executor : Executor, _ transform : @escaping (Key) throws -> T) rethrows -> [T : Value] {
        let futures : [Future<(T,Value)>] = self.map { (key, value) in
            let future : Future<(T,Value)> = executor.submit { resolver in
                resolver.set((try transform(key), value))
            }
            return future
        }
        return try! Future.batch(futures).map { elements -> [T : Value] in
            var dict = [T:Value]()
            elements.forEach { element in
                dict[element.0] = element.1
            }
            return dict
            }.result.get()
    }
    
    /// Executor-based map method
    ///
    /// - Parameters:
    ///   - executor: The executor to use on each map
    ///   - transform: The mapping closure
    /// - Returns: A dictionary with mapped values
    /// - Throws: The first mapping thrown error
    public func mapValues<T>(_ executor : Executor, _ transform : @escaping (Value) throws -> T) rethrows -> [Key : T] {
        return try map(executor) { element -> T in
            return try transform(element.value)
        }
    }
    
    /// Executor-based map method
    ///
    /// - Parameters:
    ///   - executor: The executor to use on each map
    ///   - transform: The mapping closure
    /// - Returns: A dictionary with mapped values
    /// - Throws: The first mapping thrown error
    public func map<T>(_ executor : Executor, _ transform : @escaping ((key: Key, value: Value)) throws -> T) rethrows -> [Key : T] {
        let futures : [Future<(Key,T)>] = self.map { (key, value) in
            let future : Future<(Key,T)> = executor.submit { resolver in
                resolver.set((key, try transform((key, value))))
            }
            return future
        }
        return try! Future.batch(futures).map { elements -> [Key : T] in
            var dict = [Key:T]()
            elements.forEach { element in
                dict[element.0] = element.1
            }
            return dict
        }.result.get()
    }
}
