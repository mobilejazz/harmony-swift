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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implOied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public class Subscriber <T> {
    
    public enum MemoryReferenceType {
        case strong
        case weak
    }
    
    private let lock = NSLock()
    private var reactive : Bool = true
    private var future : Future<T>?
    private var strongFutures : [Future<T>] = []
    private var weakFutures : NSHashTable<Future<T>> = NSHashTable.weakObjects()
    
    /// Default initializer.
    public init () {
        // Nothing to be done
    }
    
    /// Default initializer.
    /// Note that this class will open the then closure of the future passed on this method.
    ///
    /// - Parameter future: The future to be used
    public init (_ future: Future<T>) {
        setFuture(future)
    }
    
    /// Sets the future
    ///
    /// - Parameter future: The future to be set
    public func setFuture(_ future: Future<T>) {
        self.future = future
        self.reactive = future.reactive
        update()
    }
    
    /// Returns a new future
    ///
    /// - Parameter memoryReferenceType: .weak (default) if weak reference, .strong if strong reference
    /// - Returns: A new future
    public func subscribe(_ memoryReferenceType: MemoryReferenceType = .weak) -> Future<T> {
        let future = Future<T>(reactive: reactive)
        lock.lock()
        switch memoryReferenceType {
        case .strong:
            strongFutures.append(future)
        case .weak:
            weakFutures.add(future)
        }
        lock.unlock()
        return future
    }
    
    /// Unregisters a strong referenced future
    ///
    /// - Parameter future: The future to unregister
    public func unsubscribe(_ future: Future<T>) {
        lock.lock()
        for (index, element) in strongFutures.enumerated() {
            if future === element {
                strongFutures.remove(at: index)
                break
            }
        }
        lock.unlock()
    }
    
    public func unsubscribe() {
        lock.lock()
        strongFutures.removeAll()
        lock.unlock()
    }
    
    private func update() {
        if let future = future {
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
