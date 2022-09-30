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

import Harmony

public extension Interactor {
    // swiftlint:disable unavailable_function
    class MockPutByQuery<T>: PutByQuery<T> {
        private let expectedResult: Result<T, Error>

        public required init(expectedResult: Result<T, Error>) {
            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository(InMemoryDataSource()))
        }

        public required init<R>(_: Executor, _: R) where T == R.T, R: PutRepository {
            fatalError("init(_:_:) has not been implemented")
        }

        public var spyExecuteValue: [T?] = []
        public var executeCounter: Int {
            spyExecuteValue.count
        }

        public var spyQuery: [Query?] = []
        public var spyOperation: [Harmony.Operation] = []

        @discardableResult
        override public func execute(
            _ value: T? = nil,
            query: Query = VoidQuery(),
            _ operation: Harmony.Operation = DefaultOperation(),
            in _: Harmony.Executor? = nil
        ) -> Future<T> {
            spyExecuteValue.append(value)
            spyQuery.append(query)
            spyOperation.append(operation)

            switch expectedResult {
            case let .success(value):
                return Future(value)
            case let .failure(error):
                return Future(error)
            }
        }

        public var spyId: [Any] = []

        @discardableResult
        override public func execute<K>(_ value: T?, forId id: K,
                                        _ operation: Harmony.Operation = DefaultOperation(),
                                        in _: Executor? = nil) -> Future<T>
            where K: Hashable {
            spyExecuteValue.append(value)
            spyId.append(id)
            spyOperation.append(operation)

            switch expectedResult {
            case let .success(value):
                return Future(value)
            case let .failure(error):
                return Future(error)
            }
        }
    }

    class MockPut<T>: Put<T> {
        private let expectedResult: Result<T, Error>

        public required init(expectedResult: Result<T, Error>) {
            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository(InMemoryDataSource()), VoidQuery())
        }

        public required init<R>(_: Executor, _: R, _: Query) where T == R.T, R: PutRepository {
            fatalError("init(_:_:_:) has not been implemented")
        }

        public var spyExecuteValue: [T?] = []
        public var executeCounter: Int {
            spyExecuteValue.count
        }

        public var spyOperation: [Harmony.Operation] = []

        @discardableResult
        override public func execute(
            _ value: T? = nil,
            _ operation: Harmony.Operation = DefaultOperation(),
            in _: Executor? = nil
        ) -> Future<T> {
            spyExecuteValue.append(value)
            spyOperation.append(operation)

            switch expectedResult {
            case let .success(value):
                return Future(value)
            case let .failure(error):
                return Future(error)
            }
        }
    }

    class MockPutAllByQuery<T>: PutAllByQuery<T> {
        private let expectedResult: Result<[T], Error>

        public required init(expectedResult: Result<[T], Error>) {
            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository(InMemoryDataSource()))
        }

        public required init<R>(_: Executor, _: R) where T == R.T, R: PutRepository {
            fatalError("init(_:_:) has not been implemented")
        }

        public var spyExecuteValue: [[T]] = []
        public var executeCounter: Int {
            spyExecuteValue.count
        }

        public var spyQuery: [Query?] = []
        public var spyOperation: [Harmony.Operation] = []

        @discardableResult
        override public func execute(
            _ array: [T] = [],
            query: Query = VoidQuery(),
            _ operation: Harmony.Operation = DefaultOperation(),
            in _: Executor? = nil
        ) -> Future<[T]> {
            spyExecuteValue.append(array)
            spyQuery.append(query)
            spyOperation.append(operation)

            switch expectedResult {
            case let .success(value):
                return Future(value)
            case let .failure(error):
                return Future(error)
            }
        }

        public var spyId: [Any] = []

        @discardableResult
        override public func execute<K>(_ array: [T] = [], forId id: K,
                                        _ operation: Harmony.Operation = DefaultOperation(),
                                        in _: Executor? = nil) -> Future<[T]>
            where K: Hashable {
            spyExecuteValue.append(array)
            spyOperation.append(operation)
            spyId.append(id)

            switch expectedResult {
            case let .success(value):
                return Future(value)
            case let .failure(error):
                return Future(error)
            }
        }
    }

    class MockPutAll<T>: PutAll<T> {
        private let expectedResult: Result<[T], Error>

        public required init(expectedResult: Result<[T], Error>) {
            self.expectedResult = expectedResult
            super.init(DirectExecutor(), SingleDataSourceRepository(InMemoryDataSource()), VoidQuery())
        }

        public required init<R>(_: Executor, _: R, _: Query) where T == R.T, R: PutRepository {
            fatalError("init(_:_:_:) has not been implemented")
        }

        public var spyExecuteValue: [[T]] = []
        public var executeCounter: Int {
            spyExecuteValue.count
        }

        public var spyOperation: [Harmony.Operation] = []

        @discardableResult
        override public func execute(
            _ array: [T] = [],
            _ operation: Harmony.Operation = DefaultOperation(),
            in _: Executor? = nil
        ) -> Future<[T]> {
            spyExecuteValue.append(array)
            spyOperation.append(operation)

            switch expectedResult {
            case let .success(value):
                return Future(value)
            case let .failure(error):
                return Future(error)
            }
        }
    }
}
