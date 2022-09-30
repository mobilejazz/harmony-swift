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
/// Abstract definition of an executor.
///
public protocol Executor {
    /// The executor name
    var name: String? { get }

    /// var indicating if the executor is executing
    var executing: Bool { get }

    /// Submits a closure for its execution
    ///
    /// - Parameter closure: The code to be executed. The closure must call its subclosure after completing (either sync or async)
    /// - Returns: Nothing (Void)
    func submit(_ closure: @escaping (@escaping () -> Void) -> Void)
}

///
/// Refined type of Executor that delays execution of a closure
///
public protocol DelayedExecutor: Executor {

    /// Submits a closure for execution later in time
    /// - Parameters:
    ///   - after: amount of time elapsed before the closure gets executed
    ///   - closure: The code to be executed. The closure must call its subclosure after completing (either sync or async)
    /// - Returns: Nothing (Void)
    func submit(after: DispatchTime, _ closure: @escaping (@escaping () -> Void) -> Void)

    /// Submits a closure for execution later in time
    /// - Parameters:
    ///   - after: amount of time elapsed before the closure gets executed
    ///   - closure: The code to be executed. The closure must call its subclosure after completing (either sync or async)
    /// - Returns: Nothing (Void)
    @discardableResult
    func submit(after: DispatchTime, _ closure:  @escaping () throws -> Void) -> Future<Void>
}

private let lock = NSLock()
private var counter: Int = 0

extension Executor {
    /// Creates a unique executor name
    ///
    /// - Returns: An executor name
    static public func nextExecutorName() -> String {
        lock.lock()
        counter += 1
        defer { lock.unlock() }
        return "com.mobilejazz.executor.\(counter)"
    }
}
