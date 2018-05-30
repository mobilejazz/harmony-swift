//
// Copyright 2017 Mobile Jazz SL
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

///
/// OperationQueue based executor
///
public class OperationQueueExecutor: Executor {
    
    /// The operation queue
    public let operationQueue : OperationQueue
    
    public var executing: Bool { return operationQueue.operationCount > 0 }
    
    /// The queue type
    ///
    /// - serialQueue: Serial queue
    /// - concurrentQueue: Concurrent queue
    public enum QueueType {
        case serial
        case concurrent(count:Int)
    }
    
    /// Main initializer
    ///
    /// - Parameter operationQueue: The operation queue
    public init(_ operationQueue: OperationQueue) {
        self.operationQueue = operationQueue
    }
    
    /// Convenience initalizer
    ///
    /// - Parameters:
    ///   - type: The type of queue
    ///   - name: The name of the queue
    public convenience init (type : QueueType = .serial, name: String = UUID().uuidString) {
        let operationQueue = OperationQueue()
        operationQueue.name = name
        switch type {
        case .serial:
            operationQueue.maxConcurrentOperationCount = 1
        case .concurrent(let count):
            operationQueue.maxConcurrentOperationCount = count
        }
        self.init(operationQueue)
    }
    
    public func submit(_ closure: @escaping (@escaping () -> Void) -> Void) {
        operationQueue.addOperation {
            let sempahore = DispatchSemaphore(value: 0)
            closure {
                sempahore.signal()
            }
            sempahore.wait()
        }
    }
}
