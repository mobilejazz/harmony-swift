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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implOied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public extension Observable {
    
    /// Adds a delay to the then call
    public func withDelay(_ interval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        return Observable() { resolver in
            queue.asyncAfter(deadline: .now() + interval) {
                self.resolve(success: {value in
                    resolver.set(value)
                }, failure: { error in
                    resolver.set(error)
                })
            }
        }
    }
    
    /// Calls the then block after the given deadline
    public func after(_ deadline: DispatchTime, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        return Observable() { resolver in
            queue.asyncAfter(deadline: deadline) {
                self.resolve(success: {value in
                    resolver.set(value)
                }, failure: { error in
                    resolver.set(error)
                })
            }
        }
    }
    
    /// Ensures the observable is called after the given date.
    /// If the date is earlier than now, nothing happens.
    public func after(_ date: Date) -> Observable<T> {
        let interval = date.timeIntervalSince(Date())
        if interval < 0 {
            return self
        } else {
            return withDelay(interval)
        }
    }
}
