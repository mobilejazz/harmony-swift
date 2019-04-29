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
    
    /// Adds a delay to the then call.
    ///
    /// - Parameters:
    ///   - interval: The delay time
    ///   - queue: The queue to schedule the delay (by default the Main Queue).
    /// - Returns: A chained observable.
    func withDelay(_ interval: TimeInterval, queue: DispatchQueue) -> Observable<T> {
        return Observable(parent: self) { resolver in
            queue.asyncAfter(deadline: .now() + interval) { [weak self] in
                self?.resolve(success: {value in
                    resolver.set(value)
                }, failure: { error in
                    resolver.set(error)
                })
            }
        }
    }
    
    /// Adds a sync delay (blocks current thread) after the future is resolved.
    ///
    /// - Parameters:
    ///   - interval: The delay time
    /// - Returns: A chained future.
    func withBlockingDelay(_ interval: TimeInterval) -> Observable<T> {
        if interval == 0.0 {
            return self
        }
        
        return Observable(parent: self) { resolver in
            Thread.sleep(forTimeInterval: interval)
            resolve(success: { value in
                resolver.set(value)
            }, failure: { error in
                resolver.set(error)
            })
        }
    }
    
    /// Calls the then block after the given deadline
    ///
    /// - Parameters:
    ///   - deadline: The deadline
    ///   - queue: The queue to schedule the delay (by default the Main Queue).
    /// - Returns: A chained observable.
    func after(_ deadline: DispatchTime, queue: DispatchQueue) -> Observable<T> {
        return Observable(parent: self) { resolver in
            queue.asyncAfter(deadline: deadline) { [weak self] in
                self?.resolve(success: {value in
                    resolver.set(value)
                }, failure: { error in
                    resolver.set(error)
                })
            }
        }
    }
    
    /// Ensures the observable is called after the given date.
    /// If the date is earlier than now, nothing happens.
    ///
    /// - Parameter date: The date.
    /// - Returns: A chained observable.
    func after(_ date: Date, queue: DispatchQueue) -> Observable<T> {
        let interval = date.timeIntervalSince(Date())
        if interval <= 0.0 {
            return self
        } else {
            return withDelay(interval, queue: queue)
        }
    }
}
