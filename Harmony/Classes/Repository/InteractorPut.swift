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
    public class PutByQuery<T> {
        
        private let executor : Executor
        private let repository: AnyPutRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R) where R:PutRepository, R.T == T {
            self.executor = executor
            self.repository = repository.asAnyPutRepository()
        }
        
        @discardableResult
        public func execute(_ value: T? = nil, query: Query = VoidQuery(), _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<T> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.put(value, in: query, operation: operation))
            }
        }
        
        @discardableResult
        public func execute<K>(_ value: T?, forId id: K, _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<T> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.put(value, forId: id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic put object interactor
    ///
    public class Put<T> {
        
        private let query : Query
        private let executor : Executor
        private let repository: AnyPutRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R, _ query: Query) where R:PutRepository, R.T == T {
            self.query = query
            self.executor = executor
            self.repository = repository.asAnyPutRepository()
        }
        
        public convenience init<R,K>(_ executor: Executor, _ repository: R, _ id: K) where K:Hashable, R:PutRepository, R.T == T {
            self.init(executor, repository, IdQuery(id))
        }
        
        @discardableResult
        public func execute(_ value: T? = nil, _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<T> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.put(value, in: self.query, operation: operation))
            }
        }
    }
    
    ///
    /// Generic put objects by query interactor
    ///
    public class PutAllByQuery<T> {
        
        private let executor : Executor
        private let repository: AnyPutRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R) where R : PutRepository, R.T == T {
            self.executor = executor
            self.repository = repository.asAnyPutRepository()
        }
        
        @discardableResult
        public func execute(_ array: [T] = [], query: Query = VoidQuery(), _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<[T]> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.putAll(array, in: query, operation: operation))
            }
        }
        
        @discardableResult
        public func execute<K>(_ array: [T] = [], forId id: K, _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<[T]> where K:Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.putAll(array, forId: id, operation: operation))
            }
        }
    }
    
    ///
    /// Generic put objects interactor
    ///
    public class PutAll<T> {
        
        private let query : Query
        private let executor : Executor
        private let repository: AnyPutRepository<T>
        
        public required init<R>(_ executor: Executor, _ repository: R, _ query: Query) where R:PutRepository, R.T == T {
            self.query = query
            self.executor = executor
            self.repository = repository.asAnyPutRepository()
        }
        
        public convenience init<R,K>(_ executor: Executor, _ repository: R, _ id: K) where K:Hashable, R:PutRepository, R.T == T {
            self.init(executor, repository, IdQuery(id))
        }
        
        @discardableResult
        public func execute(_ array: [T] = [], _ operation: Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<[T]> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.putAll(array, in: self.query, operation: operation))
            }
        }
    }
}

extension PutRepository {
    public func toPutByQueryInteractor(_ executor: Executor) -> Interactor.PutByQuery<T> {
        return Interactor.PutByQuery(executor, self)
    }
    
    public func toPutInteractor(_ executor: Executor, _ query : Query) -> Interactor.Put<T> {
        return Interactor.Put<T>(executor, self, query)
    }
    
    public func toPutInteractor<K>(_ executor: Executor, _ id : K) -> Interactor.Put<T> where K:Hashable {
        return Interactor.Put<T>(executor, self, id)
    }
    
    public func toPutAllByQueryInteractor(_ executor: Executor) -> Interactor.PutAllByQuery<T> {
        return Interactor.PutAllByQuery(executor, self)
    }
    
    public func toPutAllInteractor(_ executor: Executor, _ query : Query) -> Interactor.PutAll<T> {
        return Interactor.PutAll<T>(executor, self, query)
    }
    
    public func toPutAllInteractor<K>(_ executor: Executor, _ id : K) -> Interactor.PutAll<T> where K:Hashable {
        return Interactor.PutAll<T>(executor, self, id)
    }
}
