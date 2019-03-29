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
@testable import Harmony

class FutureSetTests: XCTestCase {
    
    func testFutureSetValue() {
        // Arrange
        let future = Future<Int>()

        // Act.
        future.set(42)

        // Assert.
        XCTAssertTrue(future.state == Future.State.waitingThen)
        XCTAssertNotNil(future._result)
        switch future._result! {
        case .value(let value):
            XCTAssertEqual(value, 42)
        case .error(_):
            XCTAssert(false)
        }
    }
    
    func testFutureSetValueTwice() {
        // Arrange.
        let future = Future<Int>()
        
        // Act.
        future.set(42)
        future.set(13)
        
        // Assert.
        XCTAssertTrue(future.state == Future.State.waitingThen)
        XCTAssertNotNil(future._result)
        switch future._result! {
        case .value(let value):
            XCTAssertEqual(value, 42)
        case .error(_):
            XCTAssert(false)
        }
    }
    
    func testFutureSetError() {
        // Arrange.
        let future = Future<Int>()
        
        // Act.
        future.set(Test.Error.code42)
        
        // Assert.
        XCTAssertTrue(future.state == Future.State.waitingThen)
        XCTAssertNotNil(future._result)
        switch future._result! {
        case .value(_):
            XCTAssert(false)
        case .error(let error):
            XCTAssertTrue(error == Test.Error.code42)
        }
    }
    
    func testFutureSetErrorTwice() {
        // Arrange.
        let future = Future<Int>()
        
        // Act.
        future.set(Test.Error.code42)
        future.set(Test.Error.code13)
        
        // Assert.
        XCTAssertTrue(future.state == Future.State.waitingThen)
        XCTAssertNotNil(future._result)
        switch future._result! {
        case .value(_):
            XCTAssert(false)
        case .error(let error):
            XCTAssertTrue(error == Test.Error.code42)
        }
    }
    
    func testFutureSetValueThenError() {
        // Arrange.
        let future = Future<Int>()
        
        // Act.
        future.set(42)
        future.set(Test.Error.code13)
        
        // Assert.
        XCTAssertTrue(future.state == Future.State.waitingThen)
        XCTAssertNotNil(future._result)
        switch future._result! {
        case .value(let value):
            XCTAssertEqual(value, 42)
        case .error(_):
            XCTAssert(false)
        }
    }
    
    func testFutureSetErrorThenValue() {
        // Arrange.
        let future = Future<Int>()
        
        // Act.
        future.set(Test.Error.code42)
        future.set(13)
        
        // Assert.
        XCTAssertTrue(future.state == Future.State.waitingThen)
        XCTAssertNotNil(future._result)
        switch future._result! {
        case .value(_):
            XCTAssert(false)
        case .error(let error):
            XCTAssertTrue(error == Test.Error.code42)
        }
    }
    
    func testFutureSetFuture1() {
        // Arrange
        let future1 = Future<Int>()
        let future2 = Future<Int>()
        
        // Act
        future1.set(42)
        future2.set(future1)
        
        // Assert.
        XCTAssertTrue(future2.state == .waitingThen)
        XCTAssertNotNil(future2._result)
        switch future2._result! {
        case .value(let value):
            XCTAssertEqual(value, 42)
        case .error(_):
            XCTAssert(false)
        }
    }
    
    func testFutureSetFuture2() {
        // Arrange
        let future1 = Future<Int>()
        let future2 = Future<Int>()
        
        // Act
        future2.set(future1)
        future1.set(42)
        
        // Assert.
        XCTAssertTrue(future2.state == .waitingThen)
        XCTAssertNotNil(future2._result)
        switch future2._result! {
        case .value(let value):
            XCTAssertEqual(value, 42)
        case .error(_):
            XCTAssert(false)
        }
    }
}
