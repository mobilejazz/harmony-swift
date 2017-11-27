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

/// Future states
public enum FutureState {
    case blank
    case waitingBlock
    case waitingValueOrError
    case sent
}

/// Observers must implement this protocol
public protocol FutureObserver : AnyObject{
    func didSendValue<T>(_ value: T?)
    func didSendError(_ error: NSError)
    func didCompleteFuture<T>(_ future: Future<T>)
}

private enum FutureError: Error {
    case valueAlreadySet
    case errorAlreadySet
    case thenAlreadySet
    case alreadySent
}

/// Future class. Wrapper of an optional value of type T or an error.
public class Future<T> {
    
    /// The future state
    public private(set) var state: FutureState = .blank
    
    /// The optional value
    public private(set) var value: T?
    
    /// The error
    public private(set) var error: NSError?
    
    private var success: ((_ value: T?) -> Void)?
    private var failure: ((_ error: NSError) -> Void)?
    private var onContentSet: (() -> Void)?
    private var isValueNil: Bool = false
    private var queue: DispatchQueue?
    private var semaphore: DispatchSemaphore?
    private let observers = NSHashTable<AnyObject>.weakObjects()
    
    /// Default initializer
    public init() {
        
    }
    
    /// Value initializer
    public init(_ value: T?) {
        set(value)
    }
    
    /// Error initializer
    public init(_ error: NSError) {
        set(error)
    }
    
    /// Future initializer
    public init(_ future: Future<T>) {
        set(future)
    }
    
    /// Sets the future value
    public func set(_ value: T?) {
        if self.value != nil || isValueNil {
            fatalError(FutureError.valueAlreadySet.localizedDescription)
        }
        
        if value == nil {
            isValueNil = true
        }
        
        self.value = value
        
        for observer in observers.allObjects {
            (observer as! FutureObserver).didSendValue(value)
        }
        
        update()
    }
    
    /// Sets the future error
    public func set(_ error: NSError) {
        if self.error != nil {
            fatalError(FutureError.errorAlreadySet.localizedDescription)
        }
    
        self.error = error
        
        for observer in observers.allObjects {
            (observer as! FutureObserver).didSendError(error)
        }
        
        update()
    }
    
    /// Sets the future with another future
    public func set(_ future: Future<T>) {
        future.then(success: { (value) in
            self.set(value)
        }, failure: { (error) in
            self.set(error)
        })
    }
    
    /// Sets both future and value together. If error, the error is set, otherwise the optional value is set.
    public func set(value: T?, error: NSError?) {
        if error != nil {
            set(error!)
        } else {
            set(value)
        }
    }
    
    /// Closure called right after content is set, without waiting the then closure.
    /// Note that multiple calls to this method are discouraged, resulting with only one onContentSet closure being called.
    ///
    /// - Parameter closure: The code to be executed
    /// - Returns: The self instance
    @discardableResult
    public func onContentSet(_ closure: @escaping () -> Void) -> Future<T> {
        switch state {
        case .waitingBlock:
            closure()
        case .blank:
            onContentSet = closure
        case .waitingValueOrError:
            onContentSet = closure
        case .sent:
            closure()
        }
        return self
    }
    
    /// Then closure executed in the given queue
    ///
    /// - Parameter queue: The dispatch queue to call the then closure
    /// - Returns: The self instance
    public func inQueue(_ queue: DispatchQueue) -> Future<T> {
        self.queue = queue
        return self
    }
    
    /// Then closure executed in the main queue
    public func inMainQueue() -> Future<T> {
        self.queue = DispatchQueue.main
        return self
    }
    
    /// Synchronous then
    public func then() -> (T?, NSError?) {
        switch state {
        case .waitingBlock:
            state = .sent
            return (value, error)
        case .blank:
            semaphore = DispatchSemaphore(value: 0)
            DispatchSemaphore.wait(semaphore!)()
            return then()
        case .waitingValueOrError:
            fatalError(FutureError.thenAlreadySet.localizedDescription)
        case .sent:
            fatalError(FutureError.alreadySent.localizedDescription)
        }
    }
    
    /// Then closure: delivers the optional value or the error
    public func then(success: @escaping (_ value: T?) -> Void, failure: @escaping (_ error: NSError) -> Void) {
        if self.success != nil || self.failure != nil {
            fatalError(FutureError.thenAlreadySet.localizedDescription)
        }
        
        self.success = success
        self.failure = failure
        
        update()
    }
        
    /// Adds an observer
    public func addObserver(_ observer: FutureObserver) {
        observers.add(observer)
        
        if state == .sent {
            observer.didCompleteFuture(self)
        }
    }
    
    /// Removes an observer
    public func removeObserver(_ observer: FutureObserver) {
        observers.remove(observer)
    }

    private func update() {
        switch state {
        case .sent:
            fatalError(FutureError.alreadySent.localizedDescription)
        case .blank:
            // Waiting for either value||error , or the then block.
            
            if value != nil || error != nil {
                state = .waitingBlock
                if let onContentSet = onContentSet {
                    onContentSet()
                    self.onContentSet = nil
                }
                if semaphore != nil {
                    DispatchSemaphore.signal(semaphore!)()
                }
            } else if (success != nil) {
                state = .waitingValueOrError
            }
        case .waitingBlock:
            if success != nil {
                send()
                state = .sent
            }
        case .waitingValueOrError:
            if (value != nil || isValueNil) || error != nil {
                if let onContentSet = onContentSet {
                    onContentSet()
                    self.onContentSet = nil
                }
                send()
                state = .sent
            }
        }
    }
    
    private func send() {
        if let queue = queue {
            let success = self.success
            let failure = self.failure
            let error = self.error
            let value = self.value
            
            queue.async {
                if error != nil {
                    failure!(error!)
                } else {
                    success!(value)
                }
            }
        } else {
            if error != nil {
                failure!(error!)
            } else {
                success!(value)
            }
        }
        
        for observer in observers.allObjects {
            (observer as! FutureObserver).didCompleteFuture(self)
        }
        
        self.success = nil
        self.failure = nil
    }
}

// MARK: Future Funtional Programming

/// Functional programming extension
public extension Future {
    
    /// Mappes the value and return a new future with the value mapped
    public func map<K>(_ transform: @escaping (T) -> K) -> Future<K> {
        let future = Future<K>()
        
        then(success: { (value) in
            if value != nil {
                future.set(transform(value!))
            } else {
                future.set(nil)
            }
        }, failure: { (error) in
            future.set(error)
        })
        
        return future
    }
    
    /// Mappes the error and return a new future with the error mapped
    public func mapError(_ transform: @escaping (_ error: NSError) -> NSError) -> Future<T> {
        let future = Future<T>()
        
        then(success: { (value) in
            future.set(value)
        }, failure: { (error) in
            future.set(transform(error))
        })
        
        return future
    }
    
    /// Intercepts the value if success and returns a new future of a mapped type to be chained
    public func flatMap<K>(_ closure: @escaping (_ value: T?) -> Future<K>) -> Future<K> {
        let future = Future<K>()
        
        then(success: { (value) in
            future.set(closure(value))
        }, failure: { (error) in
            future.set(error)
        })
        
        return future
    }
    
    /// Intercepts the error (if available) and returns a new future of type T
    public func recover(_ closure: @escaping (_ error: NSError) -> Future<T>) -> Future<T> {
        let future = Future<T>()
        
        then(success: { (value) in
            future.set(value)
        }, failure: { (error) in
            future.set(closure(error))
        })
        
        return future
    }
    
    /// Intercepts the then closure and returns a future containing the same result
    public func andThen(success: @escaping (_ value: T?) -> Void = { value in }, failure: @escaping (_ error: NSError) -> Void = { error in }) -> Future<T> {
        let future = Future<T>()
        
        then(success: { (value) in
            success(value)
            future.set(value)
        }, failure: { (error) in
            failure(error)
            future.set(error)
        })
        
        return future
    }
    
    @discardableResult
    public func onCompletion(_ closure: @escaping () -> Void) -> Future<T> {
        let future = Future<T>()
        
        then(success: { (value) in
            closure()
            future.set(value)
        }, failure: { (error) in
            closure()
            future.set(error)
        })
        
        return future
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K>(_ futureK: Future<K>) -> Future<(T?,K?)> {
        return self.flatMap { (valueT) -> Future<(T?,K?)> in
            return futureK.map({ (valueK) -> (T?,K?) in
                return (valueT, valueK)
            })
        }
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K,L>(_ futureK: Future<K>, _ futureL: Future<L>) -> Future<(T?,K?,L?)> {
        return self.zip(futureK).flatMap { (valueTK) -> Future<(T?,K?,L?)> in
            return futureL.map({ (valueL) -> (T?,K?,L?) in
                return (valueTK!.0, valueTK!.1, valueL)
            })
        }
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K,L,M>(_ futureK: Future<K>, _ futureL: Future<L>, _ futureM: Future<M>) -> Future<(T?,K?,L?,M?)> {
        return self.zip(futureK, futureL).flatMap { (valueTKL) -> Future<(T?,K?,L?,M?)> in
            return futureM.map({ (valueM) -> (T?,K?,L?,M?) in
                return (valueTKL!.0, valueTKL!.1, valueTKL!.2, valueM)
            })
        }
    }
}

/// To String extension
extension Future : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch state {
        case .blank:
            return "Empty future. Waiting for value, error and then closure."
        case .waitingBlock:
            if error != nil {
                return "Future waiting for then closure and error set to: \(error!)"
            } else {
                if value != nil {
                    return "Future waiting for then closure and value set to nil."
                } else {
                    return "Future waiting for then closure and value set to: \(value!)"
                }
            }
        case .waitingValueOrError:
            return "Future then closure set. Waiting for value or error."
        case .sent:
            if error != nil {
                return "Future sent with error: \(error!)"
            } else {
                if value != nil {
                    return "Future sent with nil value."
                } else {
                    return "Future sent with value: \(value!)"
                }
            }
        }
    }
    
    public var debugDescription: String {
        return description
    }
}
