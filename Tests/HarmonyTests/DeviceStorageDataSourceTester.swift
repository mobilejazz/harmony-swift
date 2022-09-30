//
//  DeviceStorageDataSource.swift
//  HarmonyTests
//
//  Created by Fran Montiel on 7/9/22.
//

import Foundation
import Harmony
import Nimble
import XCTest

struct DeviceStorageDataSourceObjectMother {
    let deviceStorageType: DeviceStorageType

    func provideDataSource<T>(
        userDefaults: UserDefaults,
        insertValue: (IdQuery<String>, T)? = nil,
        insertValues: (IdQuery<String>, [T])? = nil
    ) throws -> DeviceStorageDataSource<T> {
        let dataSource = DeviceStorageDataSource<T>(userDefaults, storageType: deviceStorageType)

        if let insertValue = insertValue {
            try dataSource.put(insertValue.1, in: insertValue.0).result.get()
        }

        if let insertValues = insertValues {
            try dataSource.putAll(insertValues.1, in: insertValues.0).result.get()
        }

        return dataSource
    }
}

class DeviceStorageDataSourceTester {
    let dataSourceObjectMother: DeviceStorageDataSourceObjectMother

    init(_ dataSourceObjectMother: DeviceStorageDataSourceObjectMother) {
        self.dataSourceObjectMother = dataSourceObjectMother
    }

    let userDefaults = UserDefaults.standard

    private func provideDataSource<T>(
        insertValue: (IdQuery<String>, T)? = nil,
        insertValues: (IdQuery<String>, [T])? = nil
    ) throws -> DeviceStorageDataSource<T> {
        return try dataSourceObjectMother.provideDataSource(
            userDefaults: userDefaults,
            insertValue: insertValue,
            insertValues: insertValues
        )
    }

    func tearDown() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }

    func test_get_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = Int.random()
        let dataSource = try provideDataSource(insertValue: (query, expectedValue))

        // When
        let actualValue = try dataSource.get(query).result.get()

        // Then
        expect(actualValue).to(equal(expectedValue))
    }

    func test_getAll_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = [Int.random(), Int.random()]
        let dataSource = try provideDataSource(insertValues: (query, expectedValue))

        // When
        let actualValue = try dataSource.getAll(query).result.get()

        // Then
        expect(actualValue).to(equal(expectedValue))
    }

    func test_put_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = Int.random()
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()

        // When
        try dataSource.put(expectedValue, in: query).result.get()

        // Then
        expect {
            try dataSource.get(query).result.get()
        }.to(equal(expectedValue))
    }

    func test_put_dictionary_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = [String(randomOfLength: 8): Int.random(), String(randomOfLength: 8): Int.random()]
        let dataSource: DeviceStorageDataSource<[String: Int]> = try provideDataSource()

        // When
        try dataSource.put(expectedValue, in: query).result.get()

        // Then
        expect {
            try dataSource.get(query).result.get()
        }.to(equal(expectedValue))
    }

    func test_put_array_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = [Int.random(), Int.random()]
        let dataSource: DeviceStorageDataSource<[Int]> = try provideDataSource()

        // When
        try dataSource.put(expectedValue, in: query).result.get()

        // Then
        expect {
            try dataSource.get(query).result.get()
        }.to(equal(expectedValue))
    }

    func test_putAll_array_value_with_idQuery() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = [Int.random(), Int.random()]
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()

        // When
        try dataSource.putAll(expectedValue, in: query).result.get()

        // Then
        expect {
            try dataSource.getAll(query).result.get()
        }.to(equal(expectedValue))
    }

    func test_putAll_array_value_with_idsQuery() throws {
        // Given
        let query = IdsQuery([String(randomOfLength: 8), String(randomOfLength: 8)])
        let expectedValue = [Int.random(), Int.random()]
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()

        // When
        try dataSource.putAll(expectedValue, in: query).result.get()

        // Then
        expect {
            try dataSource.getAll(query).result.get()
        }.to(equal(expectedValue))
    }

    func test_delete_value() throws {
        // Given
        let value = Int.random()
        let query = IdQuery(String(randomOfLength: 8))
        let dataSource = try provideDataSource(insertValue: (query, value))

        // When
        try dataSource.delete(query).result.get()

        // Then
        expect {
            try dataSource.get(query).result.get()
        }
        .to(throwError(errorType: CoreError.NotFound.self))
    }

    func test_delete_all_values() throws {
        // Given
        let value = Int.random()
        let valueQuery = IdQuery(String(randomOfLength: 8))
        let values = [Int.random(), Int.random()]
        let valuesQuery = IdQuery(String(randomOfLength: 8))
        let dataSource = try provideDataSource(
            insertValue: (valueQuery, value),
            insertValues: (valuesQuery, values)
        )

        // When
        try dataSource.delete(AllObjectsQuery()).result.get()

        // Then
        expect {
            try dataSource.get(valueQuery).result.get()
        }
        .to(throwError(errorType: CoreError.NotFound.self))

        // Then
        expect {
            try dataSource.get(valuesQuery).result.get()
        }
        .to(throwError(errorType: CoreError.NotFound.self))
    }

    func test_get_value_not_found() throws {
        // Given
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()
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
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()
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
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()
        let query = VoidQuery()

        expect {
            // When
            try dataSource.get(query).result.get()
        }
        // Then
        .to(throwAssertion())
    }

    func test_getAll_non_valid_query() throws {
        // Given
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()
        let query = VoidQuery()

        expect {
            // When
            try dataSource.getAll(query).result.get()
        }
        // Then
        .to(throwAssertion())
    }

    func test_put_non_valid_query() throws {
        // Given
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()
        let query = VoidQuery()
        let value = Int.random()

        expect {
            // When
            try dataSource.put(value, in: query).result.get()
        }
        // Then
        .to(throwAssertion())
    }

    func test_putAll_non_valid_query() throws {
        // Given
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()
        let query = VoidQuery()
        let value = [Int.random(), Int.random()]

        expect {
            // When
            try dataSource.putAll(value, in: query).result.get()
        }
        // Then
        .to(throwAssertion())
    }

    func test_delete_non_valid_query() throws {
        // Given
        let dataSource: DeviceStorageDataSource<Int> = try provideDataSource()
        let query = VoidQuery()

        expect {
            // When
            try dataSource.delete(query).result.get()
        }
        // Then
        .to(throwAssertion())
    }

    func test_should_replace_previous_value_when_inserting_with_existing_key() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let firstValue = [Int.random(), Int.random()]
        let secondValue = Int.random()
        let dataSource = try provideDataSource(insertValues: (query, firstValue))

        expect {
            // When
            _ = dataSource.put(secondValue, in: query) // Put a new value using the same key
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
