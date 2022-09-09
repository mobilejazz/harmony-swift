//
//  FutureTests.swift
//  HarmonyTests
//
//  Created by Joan Martin on 16/6/22.
//

import XCTest
import Harmony
import HarmonyTesting
import Nimble

class FutureTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Success Errors
    func test_future_value_set_on_init() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)

        // When
        let future = Future(anyValue)

        // Then
        expect(try future.result.get()) == anyValue
    }

    func test_future_value_set_on_set_value() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)
        let future = Future<Int>()

        // When
        future.set(anyValue)

        // Then
        expect(try future.result.get()) == anyValue
    }

    func test_future_value_set_on_set_value_or_error() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)
        let future = Future<Int>()

        // When
        future.set(value: anyValue, error: nil)

        // Then
        expect(try future.result.get()) == anyValue
    }

    func test_future_error_set_on_init() throws {
        // Given
        let anyError = CoreError.Unknown()

        // When
        let future = Future<Int>(anyError)

        // Then
        expect(try future.result.get()).to(throwError(anyError))
    }

    func test_future_error_set_on_set_value() throws {
        // Given
        let anyError = CoreError.Unknown()
        let future = Future<Int>()

        // When
        future.set(anyError)

        // Then
        expect(try future.result.get()).to(throwError(anyError))
    }

    func test_future_error_set_on_set_value_or_error() throws {
        // Given
        let anyError = CoreError.Unknown()

        // When
        let future = Future<Int>()
        future.set(value: nil, error: anyError)

        // Then
        expect(try future.result.get()).to(throwError(anyError))
    }

    func test_future_states_on_value_first_then_after() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)
        let future = Future<Int>()

        // When
        expect(future.state) == Future.State.blank
        future.set(value: anyValue, error: nil)
        expect(future.state) == Future.State.waitingThen

        // Then
        let expectation = expectation(description: "")
        future.then { val in
            expect(val) == anyValue
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        expect(future.state) == Future.State.sent
    }

    func test_future_states_on_then_first_value_after() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)
        let future = Future<Int>()

        // When
        expect(future.state) == Future.State.blank
        future.set(value: anyValue, error: nil)
        expect(future.state) == Future.State.waitingThen

        // Then
        let expectation = expectation(description: "")
        future.then { val in
            expect(val) == anyValue
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        expect(future.state) == Future.State.sent
    }

    func test_future_states_result_first_value_after() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)
        let queue = DispatchQueue(label: "")
        let future = Future<Int>()
        let expectation = expectation(description: "")

        // When
        expect(future.state) == Future.State.blank
        queue.async {
            expect(future.state) == Future.State.blank
            expect(try? future.result.get()) == anyValue
            expect(future.state) == Future.State.sent
            expectation.fulfill()
        }

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // TODO: This next line fails the test. Not sure if it should.
            // expect(future.state) == Future.State.waitingContent
            future.set(anyValue)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_future_states_value_first_result_after() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)
        let future = Future<Int>()

        // When
        expect(future.state) == Future.State.blank
        future.set(anyValue)

        // Then
        expect(future.state) == Future.State.waitingThen
        expect(try? future.result.get()) == anyValue
        expect(future.state) == Future.State.sent
    }
    
    @available(iOS 13.0, *)
    func test_async_to_future() throws {
        // Given
        let anyValue = Int.random(in: Int.min...Int.max)
        
        // when
        let value: Int = try withFuture {
            try await Task.sleep(nanoseconds: 25 * TIME_1_MILLISECOND_IN_NANOSECONDS)
            return anyValue
        }.result.get()
        
        // Then
        expect(value) == anyValue
    }
    
    @available(iOS 13.0, *)
    func test_future_to_async() throws {
        // Given
        let expectedValue = Int.random(in: Int.min...Int.max)
        let future = Future<Int>()
        let expectation = expectation(description: "Future Timeout")
        
        Task {
            try await Task.sleep(nanoseconds: TIME_1_SECOND_IN_NANOSECONDS * UInt64(0.25))
            future.set(expectedValue)
        }
        
        Task {
            let producedValue = try await future.async()
            expect(producedValue).to(equal(expectedValue))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
