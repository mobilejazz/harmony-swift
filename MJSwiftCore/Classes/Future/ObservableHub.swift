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
/// A observable hub acts as a cloner of a given observable. It can subscribe (plug) and unsubscribe (unplug) observables that react to the original one.
///
public class ObservableHub <T> {
    
    /// Memory Reference Type
    ///
    /// - strong: Strong reference
    /// - weak: Weak reference
    public enum MemoryReferenceType {
        case strong
        case weak
    }
    
    private let lock = NSLock()
    private var strongObservables : [Observable<T>] = []
    private var weakObservables : NSHashTable<Observable<T>> = NSHashTable.weakObjects()
    
    /// The base observable to be replicated
    public var observable : Observable<T>? {
        didSet {
            update()
        }
    }
    
    /// Default initializer.
    public init () {
        // Nothing to be done
    }
    
    /// Default initializer.
    /// Note that this class will open the then closure of the observable passed on this method.
    ///
    /// - Parameter observable: The observable to be used
    public init (_ observable: Observable<T>) {
        self.observable = observable
        update()
    }
    
    /// Creates a new observable and plugs (subscribes) it to the hub
    ///
    /// - Parameter memoryReferenceType: .weak (default) if weak reference, .strong if strong reference
    /// - Returns: A new observable
    public func plug(_ memoryReferenceType: MemoryReferenceType = .weak) -> Observable<T> {
        let observable = Observable<T>()
        plug(observable, memoryReferenceType: memoryReferenceType)
        return observable
    }
    
    /// Plugs (subscribes) the given observable to the hub
    ///
    /// - Parameter observable: The observable to subscribe
    /// - Parameter memoryReferenceType: .weak (default) if weak reference, .strong if strong reference
    public func plug(_ observable: Observable<T>, memoryReferenceType: MemoryReferenceType = .weak) {
        lock.lock()
        // Store the observable
        switch memoryReferenceType {
        case .strong:
            strongObservables.append(observable)
        case .weak:
            weakObservables.add(observable)
        }
        lock.unlock()
        // Deliver the current value/error if exists
        if let result = self.observable?._result {
            switch result {
            case .value(let value):
                observable.set(value)
            case .error(let error):
                observable.set(error)
            }
        }
    }
    
    /// Unplug (unsubscribes) a observable
    ///
    /// - Parameter observable: The observable to unregister
    public func unplug(_ observable: Observable<T>) {
        lock.lock()
        weakObservables.remove(observable)
        for (index, element) in strongObservables.enumerated() {
            if observable === element {
                strongObservables.remove(at: index)
                break
            }
        }
        lock.unlock()
    }
    
    ///
    /// Unplugs (unsubscribes) all observables
    ///
    public func unplugAll() {
        lock.lock()
        weakObservables.removeAllObjects()
        strongObservables.removeAll()
        lock.unlock()
    }
    
    private func update() {
        guard let observable = observable else {
            return
        }
        
        // Then, opening the then closure
        observable.resolve(success: {value in
            self.lock.lock()
            self.weakObservables.allObjects.forEach { $0.set(value) }
            self.strongObservables.forEach { $0.set(value) }
            self.lock.unlock()
        }, failure: { error in
            self.lock.lock()
            self.weakObservables.allObjects.forEach { $0.set(error) }
            self.strongObservables.forEach { $0.set(error) }
            self.lock.unlock()
        })
    }
}
