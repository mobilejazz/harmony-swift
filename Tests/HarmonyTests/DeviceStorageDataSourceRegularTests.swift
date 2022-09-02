//
//  DeviceStorageDataSourceRegularTests.swift
//  HarmonyTests
//
//  Created by Fran Montiel on 8/9/22.
//

import Foundation
import XCTest

class DeviceStorageDataSourceRegularTests: XCTestCase {
    
    private let tester = DeviceStorageDataSourceTester(DeviceStorageDataSourceObjectMother(deviceStorageType: .regular))
    
    override func tearDown() {
        tester.tearDown()
    }
    
    func test_get_value() throws {
        try tester.test_get_value()
    }
    
    func test_getAll_value() throws {
        try tester.test_getAll_value()
    }
    
    func test_put_value() throws {
        try tester.test_put_value()
    }
    
    func test_put_dictionary_value() throws {
        try tester.test_put_dictionary_value()
    }
    
    func test_put_array_value() throws {
        try tester.test_put_array_value()
    }
    
    func test_putAll_array_value_with_idQuery() throws {
        try tester.test_putAll_array_value_with_idQuery()
    }
    
    func test_putAll_array_value_with_idsQuery() throws {
        try tester.test_putAll_array_value_with_idsQuery()
    }
    
    func test_delete_value() throws {
        try tester.test_delete_value()
    }
    
    func test_delete_all_values() throws {
        // TODO: decide what to do with deleteAll implementation when deviceStorageType is regular
//        try tester.test_delete_all_values()
        
    }
    
    func test_get_value_not_found() throws {
        try tester.test_get_value_not_found()
    }
    
    func test_getAll_value_not_found() throws {
        try tester.test_getAll_value_not_found()
    }
    
    func test_get_non_valid_query() throws {
        try tester.test_get_non_valid_query()
    }
    
    func test_getAll_non_valid_query() throws {
        try tester.test_getAll_non_valid_query()
    }
    
    func test_put_non_valid_query() throws {
        try tester.test_put_non_valid_query()
    }
    
    func test_putAll_non_valid_query() throws {
        try tester.test_putAll_non_valid_query()
    }
    
    func test_delete_non_valid_query() throws {
        try tester.test_delete_non_valid_query()
    }
    
    func test_should_replace_previous_value_when_inserting_with_existing_key() throws {
        try tester.test_should_replace_previous_value_when_inserting_with_existing_key()
    }
    
}
