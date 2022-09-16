//
//  AsyncExecutorTests.swift
//  HarmonyTests
//
//  Created by Joan Martin on 16/6/22.
//

import XCTest
import Harmony
import Nimble

@available(iOS 13.0.0, *)
class AsyncExecutorTests: XCTestCase {
    
    func test_atomic_executor_value() async throws {
        // Given
        let originalValue = Int.random(in: Int.min...Int.max)
        let atomicExecutor = AsyncAtomicExecutor<Int>()
        
        // When
        let value = try await atomicExecutor.submit {
            try await Task.sleep(nanoseconds: 25*TIME_1_MILLISECOND_IN_NANOSECONDS)
            return originalValue
        }
        
        // Then
        expect(value) == originalValue
    }

    func test_serial_execution_of_two_tasks() {
        // Given
        let atomicExecutor = AsyncAtomicExecutor<Int>()
        let expectation1 = CountingTestExpectation(description: "")
        let expectation2 = expectation(description: "")
        
        // When
        Task {
            _ = try await atomicExecutor.submit {
                try await Task.sleep(nanoseconds: TIME_1_SECOND_IN_NANOSECONDS)
                // notify fullfillment prior to returning
                expectation1.fulfill()
                return Int.random(in: Int.min...Int.max)
            }
        }
        
        Task {
            _ = try await atomicExecutor.submit {
                // Then
                // Code block must not start until first expectation is fulfilled
                expect(expectation1.count) == 1
                
                try await Task.sleep(nanoseconds: TIME_1_SECOND_IN_NANOSECONDS)
                return Int.random(in: Int.min...Int.max)
            }
            
            // Notify fullfillment upon compleating all checks
            expectation2.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
}
