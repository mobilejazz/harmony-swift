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

class FutureInitTests: XCTestCase {
    
    func testFutureEmptyConstructor() {
        // Arrange & Act.
        let future = Future<Void>()
        
        // Assert.
        XCTAssertTrue(future.state == Future.State.blank)
    }
    
    func testFutureValueConstructor() {
        // Arrange & Act.
        let future = Future<Int>(42)
        
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
    
    func testFutureErrorConstructor() {
        // Arrange & Act.
        let future = Future<Int>(Test.Error.code42)
        
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
    
    func testFutureFutureValueConstructor() {
        // Arrange & Act.
        let f = Future<Int>(42)
        let future = Future<Int>(f)
        
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
    
    func testFutureFutureErrorConstructor() {
        // Arrange & Act.
        let f = Future<Int>(Test.Error.code42)
        let future = Future<Int>(f)
        
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
    
    func testFutureClosureValueConstructor() {
        let future = Future<Int>() { future in
            future.set(42)
        }
        
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
    
    func testFutureClosureErrorConstructor() {
        let future = Future<Int>() { future in
            future.set(Test.Error.code42)
        }
        
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
    
    func testFutureClosureErrorThrowConstructor() {
        let future = Future<Int>() { future in
            throw Test.Error.code42
        }
        
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
    
    func testFutureDirectClosureValueConstructor() {
        let future = Future<Int>(value: { 42 })
        
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
    
    func testFutureDirectClosureErrorConstructor() {
        let future = Future<Int>() { Test.Error.code42 }
        
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
    
    func testFutureDirectClosureErrorThrowConstructor() {
        let future = Future<Int>(value: { throw Test.Error.code42 })
        
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
}
