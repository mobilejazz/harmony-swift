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

extension Interactor {
    ///
    /// Generic put object by query interactor
    ///
    public class PutByQuery <T> : QueryInteractor<T> {
        public func execute(_ value: T, query: Query, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<T> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.put(value, in: query, operation: operation))
            }
        }
        
        public func execute<K>(_ value: T, forId id: K, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<T> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.put(value, forId: id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic put object interactor
    ///
    public class Put <T> : DirectInteractor<T> {
        public func execute(_ value: T, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<T> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.put(value, in: self.query, operation: operation))
            }
        }
    }
    
    ///
    /// Generic put objects by query interactor
    ///
    public class PutAllByQuery <T> : QueryInteractor <T> {
        public func execute(_ array: [T], query: Query, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<[T]> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.putAll(array, in: query, operation: operation))
            }
        }
        
        public func execute<K>(_ array: [T], forId id: K, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<[T]> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.putAll(array, forId: id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic put objects interactor
    ///
    public class PutAll <T> : DirectInteractor <T> {
        public func execute(_ array: [T], _ operation: Operation = .none, in executor: Executor? = nil) -> Future<[T]> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.putAll(array, in: self.query, operation: operation))
            }
        }
    }
}
