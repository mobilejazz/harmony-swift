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
    
    public let queue : DispatchQueue
    
    public private(set) var executing = false
    
    public convenience init() {
        self.init(DispatchQueue(label: UUID().uuidString))
    }
    
    public init(_ queue: DispatchQueue) {
        self.queue = queue
    }
        
    public func submit(_ closure: @escaping (@escaping () -> Void) -> Void) {
        queue.async {
            self.executing = true
            let sempahore = DispatchSemaphore(value: 0)
            closure {
                sempahore.signal()
            }
            sempahore.wait()
            self.executing = false
        }
    }
}
