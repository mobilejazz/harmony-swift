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
    /// Generic get object interactor
    ///
    public class GetByQuery <T> : QueryInteractor <T> {
        public func execute(_ query: Query, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<T?> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.get(query, operation: operation))
            }
        }
        
        public func execute<K>(_ id: K, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<T?> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.get(id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic get object interactor with a prefilled query
    ///
    public class Get <T> : DirectInteractor <T> {
        public func execute(_ operation: Operation = .none, in executor: Executor? = nil) -> Future<T?> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.get(self.query, operation: operation))
            }
        }
    }
    
    ///
    /// Generic get objects interactor
    ///
    public class GetAllByQuery <T> : QueryInteractor <T> {
        public func execute(_ query: Query = AllObjectsQuery(), _ operation: Operation = .none, in executor: Executor? = nil) -> Future<[T]> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.getAll(query, operation: operation))
            }
        }
        
        public func execute<K>(_ id: K, _ operation: Operation = .none, in executor: Executor? = nil) -> Future<[T]> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.getAll(id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic get all objects interactor
    ///
    public class GetAll <T> : DirectInteractor <T>{
        public func execute(_ operation: Operation = .none, in executor: Executor? = nil) -> Future<[T]> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.getAll(self.query, operation: operation))
            }
        }
    }
}
