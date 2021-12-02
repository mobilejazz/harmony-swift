//
// Copyright 2021 Mobile Jazz SL
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

#if DEBUG

public extension Interactor {
    
    class MockDeleteByQuery: DeleteByQuery {
        private let expectedResult: Result<Void, Error>

        public required init(expectedResult: Result<Void, Error>) {
            
            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository<InMemoryDataSource<Any>, Any>(InMemoryDataSource()))
        }

        required init(_ executor: Executor, _ repository: DeleteRepository) {
            fatalError("init(_:_:) has not been implemented")
        }


        var spyQuery: [Query?] = []
        var spyOperation: [Harmony.Operation] = []
        var executeCounter: Int {
            spyOperation.count
        }

        @discardableResult
        override public func execute(_ query: Query, _ operation: Harmony.Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<Void> {

            self.spyOperation.append(operation)
            self.spyQuery.append(query)

            switch self.expectedResult {
            case .success(let value):
                return Future(value)
            case .failure(let error):
                return Future(error)
            }
        }

        var spyId: [Any] = []

        @discardableResult
        override public func execute<K>(_ id: K, _ operation: Harmony.Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<Void> where K: Hashable {

            self.spyOperation.append(operation)
            self.spyId.append(id)

            switch self.expectedResult {
            case .success(let value):
                return Future(value)
            case .failure(let error):
                return Future(error)
            }
        }
    }

    class MockDelete: Delete {
        private let expectedResult: Result<Void, Error>

        public required init(expectedResult: Result<Void, Error>) {

            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository<InMemoryDataSource<Any>, Any>(InMemoryDataSource()), VoidQuery())
        }

        required init(_ executor: Executor, _ repository: DeleteRepository, _ query: Query) {
            fatalError("init(_:_:_:) has not been implemented")
        }

        var spyOperation: [Harmony.Operation] = []
        var executeCounter: Int {
            spyOperation.count
        }

        @discardableResult
        override public func execute(_ operation: Harmony.Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<Void> {

            self.spyOperation.append(operation)

            switch self.expectedResult {
            case .success(let value):
                return Future(value)
            case .failure(let error):
                return Future(error)
            }
        }
    }

    class MockDeleteAllByQuery: DeleteAllByQuery {
        private let expectedResult: Result<Void, Error>

        public required init(expectedResult: Result<Void, Error>) {

            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository<InMemoryDataSource<Any>, Any>(InMemoryDataSource()))
        }

        required init(_ executor: Executor, _ repository: DeleteRepository) {
            fatalError("init(_:_:) has not been implemented")
        }

        var spyQuery: [Query?] = []
        var spyOperation: [Harmony.Operation] = []
        var executeCounter: Int {
            spyOperation.count
        }

        @discardableResult
        override public func execute(_ query: Query, _ operation: Harmony.Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<Void> {

            self.spyOperation.append(operation)
            self.spyQuery.append(query)

            switch self.expectedResult {
            case .success(let value):
                return Future(value)
            case .failure(let error):
                return Future(error)
            }
        }

        var spyId: [Any] = []

        @discardableResult
        override public func execute<K>(_ id: K, _ operation: Harmony.Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<Void> where K: Hashable {

            self.spyOperation.append(operation)
            self.spyId.append(id)

            switch self.expectedResult {
            case .success(let value):
                return Future(value)
            case .failure(let error):
                return Future(error)
            }
        }
    }

    class MockDeleteAll: DeleteAll {
        private let expectedResult: Result<Void, Error>

        public required init(expectedResult: Result<Void, Error>) {

            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository<InMemoryDataSource<Any>, Any>(InMemoryDataSource()), VoidQuery())
        }

        required init(_ executor: Executor, _ repository: DeleteRepository, _ query: Query) {
            fatalError("init(_:_:_:) has not been implemented")
        }

        var spyOperation: [Harmony.Operation] = []
        var executeCounter: Int {
            spyOperation.count
        }

        @discardableResult
        override public func execute(_ operation: Harmony.Operation = DefaultOperation(), in executor: Executor? = nil) -> Future<Void> {

            self.spyOperation.append(operation)

            switch self.expectedResult {
            case .success(let value):
                return Future(value)
            case .failure(let error):
                return Future(error)
            }
        }
    }
}
#endif
