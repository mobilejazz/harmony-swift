//
// Copyright 2022 Mobile Jazz SL
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
import Nimble
import XCTest
import Harmony

class InMemoryDataSourceTests: XCTestCase {

    private func provideEmptyDataSource() -> InMemoryDataSource<Int> {
        return InMemoryDataSource<Int>()
    }

    func test_put_value() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = IdQuery(String(randomOfLength: 8))
        let value = Int.random()

        // When
        _ = try dataSource.put(value, in: query).result.get()

        // Then
        let result = try dataSource.get(query).result.get()
        expect(result).to(equal(value))
    }

    func test_putAll_value() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = IdQuery(String(randomOfLength: 8))
        let value = [Int.random(), Int.random()]

        // When
        _ = try dataSource.putAll(value, in: query).result.get()

        // Then
        let result = try dataSource.getAll(query).result.get()
        expect(result).to(equal(value))
    }

    func test_delete_value() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = IdQuery(String(randomOfLength: 8))
        let value = Int.random()
        _ = try dataSource.put(value, in: query).result.get()

        // When
        try dataSource.delete(query).result.get()

        // Then
        expect {
            try dataSource.get(query).result.get()
        }
        .to(throwError(errorType: CoreError.NotFound.self))

    }

    func test_get_value_not_found() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = IdQuery(String(randomOfLength: 8))

        expect {
            // When
            try dataSource.get(query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.NotFound.self))
    }

    func test_getAll_value_not_found() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = IdQuery(String(randomOfLength: 8))

        expect {
            // When
            try dataSource.getAll(query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.NotFound.self))
    }

    func test_get_non_valid_query() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = VoidQuery()

        expect {
            // When
            try dataSource.get(query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.QueryNotSupported.self))
    }

    func test_getAll_non_valid_query() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = VoidQuery()

        expect {
            // When
            try dataSource.getAll(query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.QueryNotSupported.self))
    }

    func test_put_non_valid_query() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = VoidQuery()
        let value = Int.random()

        expect {
            // When
            try dataSource.put(value, in: query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.QueryNotSupported.self))
    }

    func test_putAll_non_valid_query() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = VoidQuery()
        let value = [Int.random(), Int.random()]

        expect {
            // When
            try dataSource.putAll(value, in: query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.QueryNotSupported.self))
    }

    func test_delete_non_valid_query() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = VoidQuery()

        expect {
            // When
            try dataSource.delete(query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.QueryNotSupported.self))
    }

    func test_should_replace_previous_value_when_inserting_with_existing_key() throws {
        // Given
        let dataSource = provideEmptyDataSource()
        let query = IdQuery(String(randomOfLength: 8))
        let firstValue = [Int.random(), Int.random()]
        let secondValue = Int.random()
        dataSource.putAll(firstValue, in: query) // Put a list

        expect {
            // When
            dataSource.put(secondValue, in: query) // Put a new value using the same key
            return try dataSource.get(query).result.get()
        }
        // Then
        .to(equal(secondValue)) // The new value is obtained

        expect {
            // When
            try dataSource.getAll(query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.NotFound.self)) // The old value (list) is not there anymore
    }

}
