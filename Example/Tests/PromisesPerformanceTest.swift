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
import Promises

class PromisesPerformanceTest: XCTestCase {

    /// Measures the average time needed to create a resolved `Promise` and get into a `then` block
    /// chained to it.
    func testThenOnSerialQueue() {
        // Arrange.
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = Constants.iterationCount
        let queue = DispatchQueue(label: #function, qos: .userInitiated)
        let semaphore = DispatchSemaphore(value: 0)
        
        // Act.
        DispatchQueue.main.async {
            let time = dispatch_benchmark(Constants.iterationCount) {
                Promise<Bool>(true).then(on: queue) { _ in
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
    
    /// Measures the average time needed to create a resolved `Promise`, chain two `then` blocks on
    /// it and get into the last `then` block.
    func testDoubleThenOnSerialQueue() {
        // Arrange.
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = Constants.iterationCount
        let queue = DispatchQueue(label: #function, qos: .userInitiated)
        let semaphore = DispatchSemaphore(value: 0)
        
        // Act.
        DispatchQueue.main.async {
            let time = dispatch_benchmark(Constants.iterationCount) {
                Promise<Bool>(true).then(on: queue) { _ in
                    }.then(on: queue) { _ in
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
    
    /// Measures the average time needed to create a resolved `Promise`, chain three `then` blocks on
    /// it and get into the last `then` block.
    func testTripleThenOnSerialQueue() {
        // Arrange.
        let expectation = self.expectation(description: "")
        expectation.expectedFulfillmentCount = Constants.iterationCount
        let queue = DispatchQueue(label: #function, qos: .userInitiated)
        let semaphore = DispatchSemaphore(value: 0)
        
        // Act.
        DispatchQueue.main.async {
            let time = dispatch_benchmark(Constants.iterationCount) {
                Promise<Bool>(true).then(on: queue) { _ in
                    }.then(on: queue) { _ in
                    }.then(on: queue) { _ in
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
    
    /// Measures the total time needed to resolve a lot of pending `Promise` with chained `then`
    /// blocks on them on a concurrent queue and wait for each of them to get into chained block.
    func testThenOnConcurrentQueue() {
        // Arrange.
        let queue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
        let group = DispatchGroup()
        var promises = [Promise<Bool>]()
        for _ in 0..<Constants.iterationCount {
            group.enter()
            let promise = Promise<Bool>.pending()
            promise.then(on: queue) { _ in
                group.leave()
            }
            promises.append(promise)
        }
        let startDate = Date()
        
        // Act.
        for promise in promises {
            promise.fulfill(true)
        }
        
        // Assert.
        XCTAssert(group.wait(timeout: .now() + 1) == .success)
        let endDate = Date()
        print(total: endDate.timeIntervalSince(startDate))
    }
}
