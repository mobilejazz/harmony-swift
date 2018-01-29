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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

///
/// A future hub acts as a cloner of a given future. It can subscribe (plug) and unsubscribe (unplug) futures that react to the original one.
/// Typically used for reactive futures to maintain a live pipeline stream.
///
public class FutureHub <T> {
    
    /// Memory Reference Type
    ///
    /// - strong: Strong reference
    /// - weak: Weak reference
    public enum MemoryReferenceType {
        case strong
        case weak
    }
    
    private let lock = NSLock()
    private var reactive : Bool = true
    private var strongFutures : [Future<T>] = []
    private var weakFutures : NSHashTable<Future<T>> = NSHashTable.weakObjects()
    
    /// The base future to be replicated
    public var future : Future<T>? {
        didSet {
            update()
        }
    }
    
    /// Default initializer.
    public init () {
        // Nothing to be done
    }
    
    /// Default initializer.
    /// Note that this class will open the then closure of the future passed on this method.
    ///
    /// - Parameter future: The future to be used
    public init (_ future: Future<T>) {
        self.future = future
        update()
    }
    
    /// Creates a new future and plugs (subscribes) it to the hub
    ///
    /// - Parameter memoryReferenceType: .weak (default) if weak reference, .strong if strong reference
    /// - Returns: A new future
    public func plug(_ memoryReferenceType: MemoryReferenceType = .weak) -> Future<T> {
        let future = Future<T>(reactive: reactive)
        plug(future, memoryReferenceType: memoryReferenceType)
        return future
    }
    
    /// Plugs (subscribes) the given future to the hub
    ///
    /// - Parameter future: The future to subscribe
    /// - Parameter memoryReferenceType: .weak (default) if weak reference, .strong if strong reference
    public func plug(_ future: Future<T>, memoryReferenceType: MemoryReferenceType = .weak) {
        lock.lock()
        switch memoryReferenceType {
        case .strong:
            strongFutures.append(future)
        case .weak:
            weakFutures.add(future)
        }
        lock.unlock()
    }
    
    /// Unplug (unsubscribes) a future
    ///
    /// - Parameter future: The future to unregister
    public func unplug(_ future: Future<T>) {
        lock.lock()
        for (index, element) in weakFutures.allObjects.enumerated() {
            if future === element {
                weakFutures.remove(at: index)
                break
            }
        }
        for (index, element) in strongFutures.enumerated() {
            if future === element {
                strongFutures.remove(at: index)
                break
            }
        }
        lock.unlock()
    }
    
    ///
    /// Unplugs (unsubscribes) all futures
    ///
    public func unplugAll() {
        lock.lock()
        weakFutures.removeAllObjects()
        strongFutures.removeAll()
        lock.unlock()
    }
    
    private func update() {
        if let future = future {
            
            self.reactive = future.reactive
            
            // First, configuring the already created futures for reactiveness
            lock.lock()
            for element in weakFutures.allObjects {
                element.mimic(future)
            }
            for element in strongFutures {
                element.mimic(future)
            }
            lock.unlock()
            
            // Then, opening the then closure
            future.then(success: { value in
                self.lock.lock()
                for future in self.weakFutures.allObjects {
                    future.set(value)
                }
                for future in self.strongFutures {
                    future.set(value)
                }
                self.lock.unlock()
            }, failure: { error in
                self.lock.lock()
                for future in self.weakFutures.allObjects {
                    future.set(error)
                }
                for future in self.strongFutures {
                    future.set(error)
                }
                self.lock.unlock()
            })
        }
    }
}
