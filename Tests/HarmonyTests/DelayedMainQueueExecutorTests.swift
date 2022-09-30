//
//  DirectExecutorTests.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 21.09.2022..
//

import XCTest
import Nimble
import Harmony

final class DelayedMainQueueExecutorTests: XCTestCase {

    func test_submit() throws {
        // Given
        let executor = DelayedMainQueueExecutor()
        let closureIsRun = XCTestExpectation()

        // When
        executor.submit { resolver in
            resolver.set()
            XCTAssertTrue(Thread.isMainThread)
            closureIsRun.fulfill()
        }

        // Then
        wait(for: [closureIsRun], timeout: 1)
    }

    func test_submit_with_delay_overriding_delay() throws {
        // Given
        let executor = DelayedMainQueueExecutor(overrideDelay: true)
        let closureIsRun = XCTestExpectation()

        // When
        executor.submit(after: .now() + 2) { end in
            end()
            XCTAssertTrue(Thread.isMainThread)
            closureIsRun.fulfill()
        }

        // Then
        wait(for: [closureIsRun], timeout: 1)
    }

    func test_submit_with_delay_without_overriding() throws {
        // Given
        let executor = DelayedMainQueueExecutor()
        let closureIsRun = XCTestExpectation()

        // When
        executor.submit(after: .now() + 0.5) { end in
            end()
            XCTAssertTrue(Thread.isMainThread)
            closureIsRun.fulfill()
        }

        // Then
        wait(for: [closureIsRun], timeout: 0.75)
    }
}
