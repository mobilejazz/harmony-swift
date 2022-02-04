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

extension Observable {
    
    ///
    /// A hub acts as a cloner of a given observable.
    /// It can create subscribed observables, making them trigger when the main one triggers.
    ///
    public class Hub {
        
        private weak var observable : Observable<T>?
        private let lock = NSLock()
        private var subscribers : NSHashTable<Observable<T>> = NSHashTable.weakObjects()
        
        /// Default initializer.
        /// Note that this class will open the then closure of the observable passed on this method.
        ///
        /// - Parameter observable: The observable to be used
        public init (_ observable: Observable<T>) {
            self.observable = observable
            
            observable.resolve(success: {value in
                self.lock.lock()
                self.subscribers.allObjects.forEach { $0.set(value) }
                self.lock.unlock()
            }, failure: { error in
                self.lock.lock()
                self.subscribers.allObjects.forEach { $0.set(error) }
                self.lock.unlock()
            })
        }
        
        /// Creates a new observable.
        public func subscribe() -> Observable<T> {
            let subscriber = Observable<T>(parent: observable)
            
            lock.lock()
            subscribers.add(subscriber)
            lock.unlock()
            
            // Sets the current value/error if exists
            if let result = observable?._result {
                switch result {
                case .value(let value):
                    subscriber.set(value)
                case .error(let error):
                    subscriber.set(error)
                }
            }
            return subscriber
        }
        
        ///
        /// Cleans all observables
        ///
        public func clean() {
            lock.lock()
            subscribers.removeAllObjects()
            lock.unlock()
        }
    }
}
