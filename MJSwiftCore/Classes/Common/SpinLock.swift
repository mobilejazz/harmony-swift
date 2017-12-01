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

import UIKit

private class LockProvider {
    let lock = NSLock()
    let nilLock = NSLock()
    var map = NSMapTable<AnyObject, NSLock>.weakToStrongObjects()

    func lockWithScope(_ scope: AnyObject?) -> NSLock {
        lock.lock()
        defer { lock.unlock() }
        
        if let scope = scope {
            if let lock = map.object(forKey: scope) {
                return lock
            } else {
                let lock = NSLock()
                map.setObject(lock, forKey: scope)
                return lock
            }
        } else {
            return nilLock
        }
    }
}

private let lockProvider = LockProvider()

/// Easy lock sync interface inspired in a Swinject internal class and matching the usability of objc's @syncrhonized(id) { }
public class SpinLock {
    
    /// The lock
    private let lock : NSLock
    
    public init(_ scope: AnyObject? = nil) {
        lock = lockProvider.lockWithScope(scope)
    }
    
    /// The syncing method
    public func sync<T>(_ closure: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return closure()
    }
    
    /// The syncing method
    public func sync<T>(_ closure: () -> T?) -> T? {
        lock.lock()
        defer { lock.unlock() }
        return closure()
    }
    
    /// The syncing method
    public func sync(_ closure: () -> Void) {
        lock.lock()
        closure()
        lock.unlock()
    }
}

public extension SpinLock {
    convenience init(_ scope: Int) {
        self.init(NSNumber(integerLiteral: scope))
    }
}
