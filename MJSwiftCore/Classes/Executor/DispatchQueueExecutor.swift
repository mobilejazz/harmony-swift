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
/// Main queue executor
///
public class MainQueueExecutor : Executor {
    
    public let name: String = "com.apple.main-thread"
    public var executing: Bool = false
    
    public init() { }
    
    public func submit(_ closure: @escaping (@escaping () -> Void) -> Void) {
        if Thread.isMainThread {
            self.executing = true
            let sempahore = DispatchSemaphore(value: 0)
            closure { sempahore.signal() }
            sempahore.wait()
            self.executing = false
        } else {
            DispatchQueue.main.async {
                self.executing = true
                let sempahore = DispatchSemaphore(value: 0)
                closure { sempahore.signal() }
                sempahore.wait()
                self.executing = false
            }
        }
    }
}

///
/// GCD-based executor
///
public class DispatchQueueExecutor : Executor {
    
    /// The queue type
    ///
    /// - serialQueue: Serial queue
    /// - concurrentQueue: Concurrent queue
    public enum QueueType {
        case serial
        case concurrent
    }
   
    public private(set) var executing = false
    
    /// The dispatch queue
    public let queue : DispatchQueue
    
    /// Main initializer
    ///
    /// - Parameter queue: The dispatch queue
    public init(_ queue: DispatchQueue) {
        self.queue = queue
    }
    
    /// Convenience initializer
    ///
    /// - Parameter type: Queue type
    public convenience init(_ type: QueueType = .serial, name: String = OperationQueueExecutor.nextExecutorName()) {
        switch type {
        case .serial:
            let queue = DispatchQueue(label: name)
            self.init(queue)
        case .concurrent:
            let queue = DispatchQueue(label: name, attributes: .concurrent)
            self.init(queue)
        }
    }
    
    public var name: String {
        return queue.label
    }
    
    public func submit(_ closure: @escaping (@escaping () -> Void) -> Void) {
        queue.async {
            self.executing = true
            let sempahore = DispatchSemaphore(value: 0)
            closure { sempahore.signal() }
            sempahore.wait()
            self.executing = false
        }
    }
}
