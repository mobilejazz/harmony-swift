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
    /// Generic delete object by query interactor
    ///
    public class DeleteByQuery<T> : QueryInteractor<T> {
        public func execute(_ object: T? = nil, query: Query = BlankQuery(), operation: Operation = .none, in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(object, in: query, operation: operation))
            }
        }
        
        public func execute<K>(_ object: T? = nil, forId id: K, operation: Operation = .none, in executor: Executor? = nil) -> Future<Void> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(object, forId: id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic delete object interactor
    ///
    public class Delete<T> : DirectInteractor<T> {
        public func execute(_ object: T? = nil, operation: Operation = .none, in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(object, in: self.query, operation: operation))
            }
        }
    }
    
    ///
    /// Generic delete objects interactor
    ///
    public class DeleteAllByQuery<T> : QueryInteractor<T> {
        public func execute(_ objects: [T] = [], query: Query = BlankQuery(), operation: Operation = .none, in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(objects, in: query, operation: operation))
            }
        }
        
        public func execute<K>(_ objects: [T] = [], forId id: K, operation: Operation = .none, in executor: Executor? = nil) -> Future<Void> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(objects, forId: id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic delete objects interactor
    ///
    public class DeleteAll<T> : DirectInteractor<T> {
        public func execute(objects: [T] = [], operation: Operation = .none, in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(objects, in: self.query, operation: operation))
            }
        }
    }
}
