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
        let dataSoruce = provideEmptyDataSource()
        let query = IdQuery("id")
        let value = 42
        
        // When
        _ = try dataSoruce.put(value, in: query).result.get()
        
        // Then
        let result = try dataSoruce.get(query).result.get()
        expect(result).to(equal(value))
    }
    
    func test_delete_value() throws {
        // Given
        let dataSoruce = provideEmptyDataSource()
        let query = IdQuery("id")
        let value = 42
        _ = try dataSoruce.put(value, in: query).result.get()
        
        // When
        try dataSoruce.delete(query).result.get()
        do {
            // Then
            _ = try dataSoruce.get(query).result.get()
            XCTAssert(false)
        } catch {
            expect(error).to(beAnInstanceOf(CoreError.NotFound.self))
        }
    }
    
    func test_get_value_not_found() throws {
        // Given
        let dataSoruce = provideEmptyDataSource()
        let query = IdQuery("id")
        
        // When
        do {
            _ = try dataSoruce.get(query).result.get()
            XCTAssert(false)
        } catch {
            // Then
            expect(error).to(beAnInstanceOf(CoreError.NotFound.self))
        }
    }
    
    func test_get_non_valid_query() throws {
        // Given
        let dataSoruce = provideEmptyDataSource()
        let query = VoidQuery()
        
        // When
        do {
            _ = try dataSoruce.get(query).result.get()
            XCTAssert(false)
        } catch {
            // Then
            expect(error).to(beAnInstanceOf(CoreError.QueryNotSupported.self))
        }
    }
    
    func test_put_non_valid_query() throws {
        // Given
        let dataSoruce = provideEmptyDataSource()
        let query = VoidQuery()
        let value = Int.random()
        
        // When
        do {
            _ = try dataSoruce.put(value, in: query).result.get()
            XCTAssert(false)
        } catch {
            // Then
            expect(error).to(beAnInstanceOf(CoreError.QueryNotSupported.self))
        }
        
    }
    
    func test_delete_non_valid_query() throws {
        // Given
        let dataSoruce = provideEmptyDataSource()
        let query = VoidQuery()
        
        // When
        do {
            _ = try dataSoruce.delete(query).result.get()
            XCTAssert(false)
        } catch {
            // Then
            expect(error).to(beAnInstanceOf(CoreError.QueryNotSupported.self))
        }
    }
}
