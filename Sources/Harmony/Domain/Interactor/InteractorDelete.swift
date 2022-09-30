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
    open class DeleteByQuery {
        private let executor: Executor
        private let repository: DeleteRepository

        public required init(_ executor: Executor, _ repository: DeleteRepository) {
            self.executor = executor
            self.repository = repository
        }

        @discardableResult
        open func execute(_ query: Query, _ operation: Operation = DefaultOperation(),
                          in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(query, operation: operation))
            }
        }

        @discardableResult
        open func execute<K>(_ id: K, _ operation: Operation = DefaultOperation(),
                             in executor: Executor? = nil) -> Future<Void> where K: Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(id, operation: operation))
            }
        }
    }

    ///
    /// Generic delete object interactor
    ///
    open class Delete {
        private let query: Query
        private let executor: Executor
        private let repository: DeleteRepository

        public required init(_ executor: Executor, _ repository: DeleteRepository, _ query: Query) {
            self.query = query
            self.executor = executor
            self.repository = repository
        }

        public convenience init<K>(_ executor: Executor, _ repository: DeleteRepository, _ id: K)
            where K: Hashable {
            self.init(executor, repository, IdQuery(id))
        }

        @discardableResult
        open func execute(_ operation: Operation = DefaultOperation(),
                          in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.delete(self.query, operation: operation))
            }
        }
    }

    ///
    /// Generic delete objects interactor
    ///
    open class DeleteAllByQuery {
        private let executor: Executor
        private let repository: DeleteRepository

        public required init(_ executor: Executor, _ repository: DeleteRepository) {
            self.executor = executor
            self.repository = repository
        }

        @discardableResult
        open func execute(_ query: Query, _ operation: Operation = DefaultOperation(),
                          in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(query, operation: operation))
            }
        }

        @discardableResult
        open func execute<K>(_ id: K, _ operation: Operation = DefaultOperation(),
                             in executor: Executor? = nil) -> Future<Void> where K: Hashable {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(id, operation: operation))
            }
        }
    }

    ///
    /// Generic delete objects interactor
    ///
    open class DeleteAll {
        private let query: Query
        private let executor: Executor
        private let repository: DeleteRepository

        public required init(_ executor: Executor, _ repository: DeleteRepository, _ query: Query) {
            self.query = query
            self.executor = executor
            self.repository = repository
        }

        public convenience init<K>(_ executor: Executor, _ repository: DeleteRepository, _ id: K)
            where K: Hashable {
            self.init(executor, repository, IdQuery(id))
        }

        @discardableResult
        open func execute(_ operation: Operation = DefaultOperation(),
                          in executor: Executor? = nil) -> Future<Void> {
            let executor = executor ?? self.executor
            return executor.submit { resolver in
                resolver.set(self.repository.deleteAll(self.query, operation: operation))
            }
        }
    }
}

public extension DeleteRepository {
    func toDeleteByQueryInteractor(_ executor: Executor) -> Interactor.DeleteByQuery {
        return Interactor.DeleteByQuery(executor, self)
    }

    func toDeleteInteractor(_ executor: Executor, _ query: Query) -> Interactor.Delete {
        return Interactor.Delete(executor, self, query)
    }

    func toDeleteInteractor<K>(_ executor: Executor, _ id: K) -> Interactor.Delete where K: Hashable {
        return Interactor.Delete(executor, self, id)
    }

    func toDeleteAllByQueryInteractor(_ executor: Executor) -> Interactor.DeleteAllByQuery {
        return Interactor.DeleteAllByQuery(executor, self)
    }

    func toDeleteAllInteractor(_ executor: Executor, _ query: Query) -> Interactor.DeleteAll {
        return Interactor.DeleteAll(executor, self, query)
    }

    func toDeleteAllInteractor<K>(_ executor: Executor, _ id: K) -> Interactor.DeleteAll where K: Hashable {
        return Interactor.DeleteAll(executor, self, id)
    }
}
