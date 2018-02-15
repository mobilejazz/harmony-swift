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

import UIKit
import XCTest

class GCDPerformanceTests: XCTestCase {

    /// Measures the average time needed to get into a dispatch_async block.
    func testDispatchAsyncOnSerialQueue() {
        // Arrange.
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = Constants.iterationCount
        let queue = DispatchQueue(label: #function, qos: .userInitiated)
        let semaphore = DispatchSemaphore(value: 0)
        
        // Act.
        DispatchQueue.main.async {
            let time = dispatch_benchmark(Constants.iterationCount) {
                queue.async {
                    semaphore.signal()
                    expectation.fulfill()
                }
                semaphore.wait()
            }
            print(average: time)
        }
        
        // Assert.
        waitForExpectations(timeout: 10)
    }
    
    /// Measures the average time needed to get into a doubly nested dispatch_async block.
    func testDoubleDispatchAsyncOnSerialQueue() {
        // Arrange.
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = Constants.iterationCount
        let queue = DispatchQueue(label: #function, qos: .userInitiated)
        let semaphore = DispatchSemaphore(value: 0)
        
        // Act.
        DispatchQueue.main.async {
            let time = dispatch_benchmark(Constants.iterationCount) {
                queue.async {
                    queue.async {
                        semaphore.signal()
                        expectation.fulfill()
                    }
                }
                semaphore.wait()
            }
            print(average: time)
        }
        
        // Assert.
        waitForExpectations(timeout: 10)
    }
    
    /// Measures the average time needed to get into a triply nested dispatch_async block.
    func testTripleDispatchAsyncOnSerialQueue() {
        // Arrange.
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = Constants.iterationCount
        let queue = DispatchQueue(label: #function, qos: .userInitiated)
        let semaphore = DispatchSemaphore(value: 0)
        
        // Act.
        DispatchQueue.main.async {
            let time = dispatch_benchmark(Constants.iterationCount) {
                queue.async {
                    queue.async {
                        queue.async {
                            semaphore.signal()
                            expectation.fulfill()
                        }
                    }
                }
                semaphore.wait()
            }
            print(average: time)
        }
        
        // Assert.
        waitForExpectations(timeout: 10)
    }
    
    /// Measures the total time needed to perform a lot of `DispatchQueue.async` blocks on
    /// a concurrent queue.
    func testDispatchAsyncOnConcurrentQueue() {
        // Arrange.
        let queue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
        let group = DispatchGroup()
        var blocks = [() -> Void]()
        for _ in 0..<Constants.iterationCount {
            group.enter()
            blocks.append({
                group.leave()
            })
        }
        let startDate = Date()
        
        // Act.
        for block in blocks {
            queue.async {
                block()
            }
        }
        
        // Assert.
        XCTAssert(group.wait(timeout: .now() + 1) == .success)
        let endDate = Date()
        print(total: endDate.timeIntervalSince(startDate))
    }
}
