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

import XCTest
@testable import MJSwiftCore

class FutureThenTests: XCTestCase {
    
    func testFutureFirstSetAfterThen() {
        // Arrange + Act
        let future = Future<Int>(42)
        
        // Assert
        future.then() { value in
            XCTAssertEqual(value, 42)
            }.fail { _ in
                XCTAssert(false)
        }
        XCTAssertTrue(future.state == .sent)
    }
    
    func testFutureFirstThenAfterSet() {
        // Arrange
        let future = Future<Int>()
        let expectation1 = self.expectation(description: "1 then")
        
        // Assert
        XCTAssertTrue(future.state == .blank)
        future.then() { value in
            expectation1.fulfill()
            XCTAssertEqual(value, 42)
            }.fail { _ in
                XCTAssert(false)
        }
        XCTAssertTrue(future.state == .waitingContent)
        
        // Act
        future.set(42)
        
        // Assert
        XCTAssertTrue(future.state == .sent)
        
        self.wait(for: [expectation1], timeout: 1)
    }
    
    func testFutureDoubleThen() {
        // Arrange + Act
        let future = Future<Int>(42)
        
        let expectation1 = self.expectation(description: "1 then")
        let expectation2 = self.expectation(description: "2 then")
        
        // Assert
        future.then() { value in
            expectation1.fulfill()
            XCTAssertEqual(value, 42)
            }.then { value in
                expectation2.fulfill()
                XCTAssertEqual(value, 42)
            }.fail { _ in
                XCTAssert(false)
        }
        XCTAssertTrue(future.state == .sent)
        
        self.wait(for: [expectation1, expectation2], timeout: 1)
    }
    
    func testFutureLotsOfThen() {
        // Arrange + Act
        let future = Future<Int>(42)
        
        let expectation1 = self.expectation(description: "1 then")
        let expectation2 = self.expectation(description: "2 then")
        let expectation3 = self.expectation(description: "3 then")
        let expectation4 = self.expectation(description: "4 then")
        let expectation5 = self.expectation(description: "5 then")
        let expectation6 = self.expectation(description: "6 then")
        
        // Assert
        future.then() { value in
            expectation1.fulfill()
            XCTAssertEqual(value, 42)
            }.then { value in
                expectation2.fulfill()
                XCTAssertEqual(value, 42)
            }.then { value in
                expectation3.fulfill()
                XCTAssertEqual(value, 42)
            }.then { value in
                expectation4.fulfill()
                XCTAssertEqual(value, 42)
            }.then { value in
                expectation5.fulfill()
                XCTAssertEqual(value, 42)
            }.then { value in
                expectation6.fulfill()
                XCTAssertEqual(value, 42)
            }.fail { _ in
                XCTAssert(false)
        }
        XCTAssertTrue(future.state == .sent)
        
        self.wait(for: [expectation1, expectation2, expectation3, expectation4, expectation5, expectation6], timeout: 1)
    }

}
