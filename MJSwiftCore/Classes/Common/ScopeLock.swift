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

private protocol LockProvider {
    associatedtype T
    func lockWithScope(_ scope: T) -> NSLock
}

private class MapTableLockProvider<Type>: LockProvider where Type: AnyObject {
    typealias T = Type
    let lock = NSLock()
    var map = NSMapTable<Type, NSLock>.weakToStrongObjects()
    func lockWithScope(_ scope: Type) -> NSLock {
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

private class DictionaryLockProvider<Type>: LockProvider where Type : Hashable {
    typealias T = Type
    let lock = NSLock()
    var map : [Type : NSLock] = [:]
    func lockWithScope(_ scope: Type) -> NSLock {
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

private let objectLockProvider = MapTableLockProvider<AnyObject>()
private let stringLockProvider = DictionaryLockProvider<String>()
private let integerLockProvider = DictionaryLockProvider<Int>()
private let globalLock = NSLock()

/// The scope
///
/// - none: No scope defined. The ScopeLock will be instance specific.
/// - global: Global scope.
/// - object: Object-defined scope
/// - string: String-defined scope
/// - int: Integer-defined scope
public enum Scope {
    case none
    case global
    case object(AnyObject)
    case string(String)
    case int(Int)
}

/// Easy lock sync interface matching the usability of objc's @syncrhonized(var) { }
///
/// Example of usage:
///
/// func updateUser(_ user: User) -> User {
///     // Using a ScopeLock on user's id (string) to ensure
///     // no other thread is manipulating the user with the given id
///     return ScopeLock(user.id).sync {
///         [...] // update user safely
///         return user
///     }
/// }
public class ScopeLock {
    
    /// The lock
    private let lock : NSLock
    
    /// Main init
    public init(_ scope: Scope) {
        switch scope {
        case .none:
            lock = NSLock()
        case .global:
            lock = globalLock
        case .object(let object):
            lock = objectLockProvider.lockWithScope(object)
        case .string(let string):
            lock = stringLockProvider.lockWithScope(string)
        case .int(let integer):
            lock = integerLockProvider.lockWithScope(integer)
        }
    }

    /// Convenience init to access the global scope
    public convenience init() {
        self.init(.global)
    }
    
    /// Convenience init to use objects as scope
    public convenience init(_ object: AnyObject) {
        self.init(.object(object))
    }
    
    /// Convenience init to use integers as scope
    public convenience init(_ value: Int) {
        self.init(.int(value))
    }
    
    /// Convenience init to use strings as scope
    public convenience init(_ string: String) {
        self.init(.string(string))
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
