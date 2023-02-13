//
// Copyright 2023 Mobile Jazz SL
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
import Harmony
import Nimble
import XCTest

private let defaultTimeout: TimeInterval = 1.0

@available(iOS 13.0, *)
class AsyncInMemoryDataSourceTests: XCTestCase {
    private func provideEmptyDataSource() -> AsyncInMemoryDataSource<Int> {
        return AsyncInMemoryDataSource<Int>()
    }

    func test_put_value() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = IdQuery(String(randomOfLength: 8))
            let value = Int.random()

            // When
            _ = try await dataSource.put(value, in: query)

            // Then
            let result = try await dataSource.get(query)
            expect(result).to(equal(value))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_putAll_value() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = IdQuery(String(randomOfLength: 8))
            let value = [Int.random(), Int.random()]

            // When
            _ = try await dataSource.putAll(value, in: query)

            // Then
            let result = try await dataSource.getAll(query)
            expect(result).to(equal(value))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_delete_value() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = IdQuery(String(randomOfLength: 8))
            let value = Int.random()
            _ = try await dataSource.put(value, in: query)

            // When
            try await dataSource.delete(query)

            // Then
            await expect {
                try await dataSource.get(query)
            }
            .to(throwError(errorType: CoreError.NotFound.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_get_value_not_found() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = IdQuery(String(randomOfLength: 8))

            await expect {
                // When
                try await dataSource.get(query)
            }
            // Then
            .to(throwError(errorType: CoreError.NotFound.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_getAll_value_not_found() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = IdQuery(String(randomOfLength: 8))

            await expect {
                // When
                try await dataSource.getAll(query)
            }
            // Then
            .to(throwError(errorType: CoreError.NotFound.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_get_non_valid_query() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = VoidQuery()

            await expect {
                // When
                try await dataSource.get(query)
            }
            // Then
            .to(throwError(errorType: CoreError.QueryNotSupported.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_getAll_non_valid_query() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = VoidQuery()

            await expect {
                // When
                try await dataSource.getAll(query)
            }
            // Then
            .to(throwError(errorType: CoreError.QueryNotSupported.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_put_non_valid_query() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = VoidQuery()
            let value = Int.random()

            await expect {
                // When
                try await dataSource.put(value, in: query)
            }
            // Then
            .to(throwError(errorType: CoreError.QueryNotSupported.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_putAll_non_valid_query() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = VoidQuery()
            let value = [Int.random(), Int.random()]

            await expect {
                // When
                try await dataSource.putAll(value, in: query)
            }
            // Then
            .to(throwError(errorType: CoreError.QueryNotSupported.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_delete_non_valid_query() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = VoidQuery()

            await expect {
                // When
                try await dataSource.delete(query)
            }
            // Then
            .to(throwError(errorType: CoreError.QueryNotSupported.self))

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }

    func test_should_replace_previous_value_when_inserting_with_existing_key() throws {
        let expectation = expectation(description: "")

        Task {
            // Given
            let dataSource = provideEmptyDataSource()
            let query = IdQuery(String(randomOfLength: 8))
            let firstValue = [Int.random(), Int.random()]
            let secondValue = Int.random()
            _ = try await dataSource.putAll(firstValue, in: query) // Put a list

            await expect {
                // When
                _ = try await dataSource.put(secondValue, in: query) // Put a new value using the same key
                return try await dataSource.get(query)
            }
            // Then
            .to(equal(secondValue)) // The new value is obtained

            await expect {
                // When
                try await dataSource.getAll(query)
            }
            // Then
            .to(throwError(errorType: CoreError.NotFound.self)) // The old value (list) is not there anymore

            expectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout)
    }
}
