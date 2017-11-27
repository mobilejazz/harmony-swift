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

public class DispatchQueueExecutor : Executor {
    private let queue : DispatchQueue
    private let semaphore : DispatchSemaphore = DispatchSemaphore(value: 0)
    public private(set) var executing = false
    
    public init(_ queue: DispatchQueue) {
        self.queue = queue
    }
    
    private func begin(_ closure: @escaping () -> Void) {
        executing = true
        queue.async {
            closure()
            self.semaphore.wait()
        }
    }
    
    private func end(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
            executing = false
            semaphore.signal()
        } else {
            DispatchQueue.main.async {
                self.end(closure)
            }
        }
    }
    
    public func submit(_ closure: @escaping (@escaping () -> Void) -> Void) {
        begin {
            closure {
                self.end { }
            }
        }
    }
}
