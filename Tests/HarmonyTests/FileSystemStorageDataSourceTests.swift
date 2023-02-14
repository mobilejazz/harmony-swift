//
//  FileSystemStorageDataSource.swift
//  HarmonyTests
//
//  Created by Fran Montiel on 6/9/22.
//

import Foundation
import Harmony
import Nimble
import XCTest

class FileSystemStorageDataSourceTests: XCTestCase {
    private func provideDataSource(insertValue: (IdQuery<String>, Data)? = nil, insertValues: (IdQuery<String>, [Data])? = nil) throws -> FileSystemStorageDataSource {
        let dataSource = FileSystemStorageDataSource(fileManager: FileManager.default, relativePath: "test")!
        
        if let insertValue = insertValue {
            try dataSource.put(insertValue.1, in: insertValue.0).result.get()
        }
        
        if let insertValues = insertValues {
            try dataSource.putAll(insertValues.1, in: insertValues.0).result.get()
        }
        
        return dataSource
    }
    
    override func tearDown() {
        do {
            try provideDataSource().delete(AllObjectsQuery()).result.get()
        } catch {
            // The directory was not created by a particular test (e.g: no inserted value)
        }
    }
    
    func test_get_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = String(randomOfLength: 8).data(using: .utf8)!
        let dataSource = try provideDataSource(insertValue: (query, expectedValue))

        // When
        let actualValue = try dataSource.get(query).result.get()

        // Then
        expect(actualValue).to(equal(expectedValue))
    }
    
    func test_getAll_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = [String(randomOfLength: 8).data(using: .utf8)!, String(randomOfLength: 8).data(using: .utf8)!]
        let dataSource = try provideDataSource(insertValues: (query, expectedValue))

        // When
        let actualValue = try dataSource.getAll(query).result.get()

        // Then
        expect(actualValue).to(equal(expectedValue))
    }
    
    func test_put_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = String(randomOfLength: 8).data(using: .utf8)!
        let dataSource = try provideDataSource()

        // When
        try dataSource.put(expectedValue, in: query).result.get()

        // Then
        expect {
            try dataSource.get(query).result.get()
        }.to(equal(expectedValue))
    }
    
    func test_putAll_value() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        let expectedValue = [String(randomOfLength: 8).data(using: .utf8)!, String(randomOfLength: 8).data(using: .utf8)!]
        let dataSource = try provideDataSource()

        // When
        try dataSource.putAll(expectedValue, in: query).result.get()

        // Then
        expect {
            try dataSource.getAll(query).result.get()
        }.to(equal(expectedValue))
    }
    
    func test_delete_value() throws {
        // Given
        let value = String(randomOfLength: 8).data(using: .utf8)!
        let valueQuery = IdQuery(String(randomOfLength: 8))
        let dataSource = try provideDataSource(insertValue: (valueQuery, value))
        
        // When
        try dataSource.delete(valueQuery).result.get()
        
        // Then
        expect {
            try dataSource.get(valueQuery).result.get()
        }
        .to(throwError(errorType: CoreError.NotFound.self))
    }
    
    func test_delete_all_values() throws {
        // Given
        let value = String(randomOfLength: 8).data(using: .utf8)!
        let valueQuery = IdQuery(String(randomOfLength: 8))
        let values = [String(randomOfLength: 8).data(using: .utf8)!, String(randomOfLength: 8).data(using: .utf8)!]
        let valuesQuery = IdQuery(String(randomOfLength: 8))
        let dataSource = try provideDataSource(insertValue: (valueQuery, value), insertValues: (valuesQuery, values))
        
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
        let dataSource = try provideDataSource()
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
        let dataSource = try provideDataSource()
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
        let dataSource = try provideDataSource()
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
        let dataSource = try provideDataSource()
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
        let dataSource = try provideDataSource()
        let query = VoidQuery()
        let value = String(randomOfLength: 8).data(using: .utf8)!
        
        expect {
            // When
            try dataSource.put(value, in: query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.QueryNotSupported.self))
    }
    
    func test_putAll_non_valid_query() throws {
        // Given
        let dataSource = try provideDataSource()
        let query = VoidQuery()
        let value = [String(randomOfLength: 8).data(using: .utf8)!, String(randomOfLength: 8).data(using: .utf8)!]
        
        expect {
            // When
            try dataSource.putAll(value, in: query).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.QueryNotSupported.self))
    }
    
    func test_delete_non_valid_query() throws {
        // Given
        let dataSource = try provideDataSource()
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
        let query = IdQuery(String(randomOfLength: 8))
        let firstValue = [String(randomOfLength: 8).data(using: .utf8)!, String(randomOfLength: 8).data(using: .utf8)!]
        let secondValue = String(randomOfLength: 8).data(using: .utf8)!
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
