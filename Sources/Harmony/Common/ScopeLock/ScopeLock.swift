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

fileprivate protocol LockProvider {
    associatedtype K
    func lockWithScope(_ scope: K) -> NSLock
}

fileprivate class MapTableLockProvider<T>: LockProvider where T: AnyObject {
    typealias K = T
    let lock = NSLock()
    var map = NSMapTable<T, NSLock>.weakToStrongObjects()
    func lockWithScope(_ scope: T) -> NSLock {
        lock.lock()
        defer { lock.unlock() }
        if let lock = map.object(forKey: scope) {
            return lock
        } else {
            let lock = NSLock()
            map.setObject(lock, forKey: scope)
            return lock
        }
    }
}

fileprivate class DictionaryLockProvider<T>: LockProvider where T : Hashable {
    typealias K = T
    let lock = NSLock()
    var map : [T : NSLock] = [:]
    func lockWithScope(_ scope: T) -> NSLock {
        lock.lock()
        defer { lock.unlock() }
        if let lock = map[scope] {
            return lock
        } else {
            let lock = NSLock()
            map[scope] = lock
            return lock
        }
    }
}

fileprivate let objectLockProvider  = MapTableLockProvider<AnyObject>()
fileprivate let stringLockProvider  = DictionaryLockProvider<String>()
fileprivate let integerLockProvider = DictionaryLockProvider<Int>()
fileprivate let typeLockProvider = DictionaryLockProvider<String>()

/// Easy lock sync interface matching the usability of objc's @syncrhonized(var) { }
///
/// Example of usage:
///
/// func updateUser(_ user: User) -> User {
///     // Using a ScopeLock on user's id (string) to ensure
///     // no other thread is manipulating a user with the given id
///     return ScopeLock(user.id).sync {
///         [...] // update user safely
///         return user
///     }
/// }
public struct ScopeLock {
    
    /// The scope
    ///
    /// - none: No scope defined. The ScopeLock will be instance specific.
    /// - custom: Provides the lock itself
    /// - global: Global scope.
    /// - object: Object-defined scope
    /// - string: String-defined scope
    /// - int: Integer-defined scope
    public enum Scope<T> {
        case none
        case lock(NSLock)
        case global
        case object(AnyObject)
        case string(String)
        case int(Int)
    }

    /// The lock
    private let lock : NSLock
    
    /// Main init
    public init<T>(_ scope: Scope<T>) {
        switch scope {
        case .none:
            lock = NSLock()
        case .lock(let inLock):
            lock = inLock
        case .global:
            lock = typeLockProvider.lockWithScope(String(describing: T.self))
        case .object(let object):
            lock = objectLockProvider.lockWithScope(object)
        case .string(let string):
            lock = stringLockProvider.lockWithScope(string)
        case .int(let integer):
            lock = integerLockProvider.lockWithScope(integer)
        }
    }
    
    /// Init from another ScopeLock
    public init(_ scopeLock : ScopeLock) {
        lock = scopeLock.lock
    }

    /// Convenience init to access the global scope
    public init() {
        self.init(Void.self)
    }
    
    /// Convenience init to use objects as scope
    public init<T>(_ object: T) where T:AnyObject {
        self.init(Scope<Void>.object(object))
    }
    
    public init<T>(_ type: T.Type) {
        self.init(Scope<T>.global)
    }
    
    /// Convenience init to use integers as scope
    public init(_ value: Int) {
        self.init(Scope<Void>.int(value))
    }
    
    /// Convenience init to use strings as scope
    public init(_ string: String) {
        self.init(Scope<Void>.string(string))
    }
    
    /// Convenience init to use a given lock
    public init(_ lock: NSLock) {
        self.init(Scope<Void>.lock(lock))
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
    
    /// The async lock method. The nested closure must be called upon unlocking.
    public func async(_ closure: (@escaping () -> Void) -> Void) {
        lock.lock()
        closure {
            self.lock.unlock()
        }
    }
}
