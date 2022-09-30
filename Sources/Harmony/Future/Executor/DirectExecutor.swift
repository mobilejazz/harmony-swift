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
/// A direct executor executes the closure on the current queue/thread synchronously.
///
public class DirectExecutor: Executor {
    public private(set) var executing: Bool = false
    public let name: String? = "com.mobilejazz.executor.direct"

    public init() { }

    public func submit(_ closure: @escaping (@escaping () -> Void) -> Void) {
        executing = true
        let sempahore = DispatchSemaphore(value: 0)
        closure { sempahore.signal() }
        sempahore.wait()
        executing = false
    }
}

public final class DelayedMainQueueExecutor: MainDirectExecutor, DelayedExecutor {

    private let overrideDelay: Bool

    public init(overrideDelay: Bool = false) {
        self.overrideDelay = overrideDelay
    }

    public func submit(after: DispatchTime, _ closure: @escaping (@escaping () -> Void) -> Void) {
        if self.overrideDelay {
            self.submit(closure)
        } else {
            DispatchQueue.main.asyncAfter(deadline: after) {
                self.executing = true
                let sempahore = DispatchSemaphore(value: 0)
                closure { sempahore.signal() }
                sempahore.wait()
                self.executing = false
            }
        }
    }

    @discardableResult public func submit<T>(after: DispatchTime, _ closure: @escaping (FutureResolver<T>) throws -> Void) -> Future<T> {
        let future = Future<T>()
        self.submit(after: after) { end in
            future.onSet {
                end()
            }
            // Wrapping the closure with a try/catch to set errors automatically
            do {
                let resolver = FutureResolver(future)
                try closure(resolver)
            } catch let error {
                future.set(error)
            }
        }
        return future.toFuture() // Creating a new future to avoid a duplicate call to onSet to the same future
    }

    /// Submits a closure for its execution.
    ///
    /// - Parameter closure: The closure to be executed. An error can be thrown.
    /// - Returns: A future wrapping the error, if thrown.
    @discardableResult public func submit(after: DispatchTime, _ closure:  @escaping () throws -> Void) -> Future<Void> {
        return self.submit(after: after) { resolver in
            try closure()
            resolver.set()
        }
    }
}

//
/// Executes on the main queue asynchronously.
/// However, if the submit is called in the main thread, the submitted closure is directly called as in a DirectExecutor.
///
public class MainDirectExecutor: Executor {

    public let name: String? = "com.mobilejazz.executor.main-direct"
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
