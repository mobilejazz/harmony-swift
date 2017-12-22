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

/// Observers must conform to this protocol.
/// Methods are optional.
public protocol FutureObserver : AnyObject {
    func didSetValue<T>(_ value: T?)
    func didSetError(_ error: Error)
    func didCompleteFuture<T>(_ future: Future<T>)
}

public extension FutureObserver {
    func didSetValue<T>(_ value: T?) { }
    func didSetError(_ error: Error) { }
    func didCompleteFuture<T>(_ future: Future<T>) { }
}

private enum FutureError: Error {
    case contentAlreadySet
    case thenAlreadySet
    case alreadySent
    case notReactive
    
    var localizedDescription: String {
        switch (self) {
        case .contentAlreadySet:
            return "Content already set: cannot set new content once is already set."
        case .thenAlreadySet:
            return "Then already set: cannot set a new then closure once is already set."
        case .alreadySent:
            return "Future is already sent."
        case .notReactive:
            return "Future is not reactive and can't be completed"
        }
    }
}

/// Future class. Wrapper of an optional value of type T or an error.
public class Future<T> {
    
    /// Future states
    public enum State {
        case blank
        case waitingThen
        case waitingContent
        case sent
        
        var localizedDescription: String {
            switch (self) {
            case .blank:
                return "Blank: empty future"
            case .waitingThen:
                return "Waiting for Block: value or error is already set and future is waiting for a then closure."
            case .waitingContent:
                return "Waiting for Value or Error: then closure is already set and future is waiting for a value or error."
            case .sent:
                return "Sent: future has already sent the value or error to the then closure."
            }
        }
    }
    
    /// The future state
    public private(set) var state: State = .blank
    
    /// The future's result
    ///
    /// - empty: a nil value was provided
    /// - value: a value was provided
    /// - error: an error was provided
    public indirect enum Result {
        case empty
        case value(T)
        case error(Error)
    }
    
    /// The future result
    public private(set) var result : Result? = nil
    
    /// Defines if the future is reactive or not.
    public let reactive : Bool
    
    // Private variables
    private var success: ((_ value: T?) -> Void)?
    private var failure: ((_ error: Error) -> Void)?
    private var onContentSet: ((inout T?, inout Error?) -> Void)?
    private var queue: DispatchQueue?
    private var semaphore: DispatchSemaphore?
    private let observers = NSHashTable<AnyObject>.weakObjects()
    
    /// Default initializer
    public init(reactive: Bool = false) {
        self.reactive = reactive
    }
    
    /// Value initializer
    public init(_ value: T?, reactive: Bool = false) {
        self.reactive = reactive
        set(value)
    }
    
    /// Error initializer
    public init(_ error: Error, reactive: Bool = false) {
        self.reactive = reactive
        set(error)
    }
    
    /// Future initializer
    public init(_ future: Future<T>) {
        self.reactive = future.reactive
        set(future)
    }
    
    /// Future initializer
    public init(reactive: Bool = false, _ closure: (Future<T>) -> Void) {
        self.reactive = reactive
        closure(self)
    }
    
    /// Creates a new future from self
    public func toFuture() -> Future<T> {
        return Future(self)
    }
    
    /// Sets the future value
    public func set(_ value: T?) {
        set(value: value, error: nil)
    }
    
    /// Sets the future error
    public func set(_ error: Error) {
        set(value: nil, error: error)
    }
    
    /// Sets the future with another future
    public func set(_ future: Future<T>) {
        future.then(success: { (value) in
            self.set(value)
        }, failure: { (error) in
            self.set(error)
        })
    }
    
    /// Sets the future with a value if not error.
    /// Note: error is prioritary, and if not error the value will be used.
    public func set(value: T?, error: Error?) {
        if !reactive {
            if result != nil {
                fatalError(FutureError.contentAlreadySet.localizedDescription)
            }
        }
        var value : T? = value
        var error : Error? = error
        if let onContentSet = onContentSet {
            onContentSet(&value, &error)
            if !reactive {
                self.onContentSet = nil
            }
        }
        if let error = error {
            result = .error(error)
        } else {
            if let value = value {
                result = .value(value)
            } else {
                result = .empty
            }
        }
        for observer in observers.allObjects {
            let observer = observer as! FutureObserver
            switch result! {
            case .error(let error):
                observer.didSetError(error)
            case .value(let value):
                observer.didSetValue(value)
            case .empty:
                observer.didSetValue(nil as T?)
            }
        }
        update()
    }
    
    /// Closure called right after content is set, without waiting the then closure.
    /// Note that multiple calls to this method are discouraged, resulting with only one onContentSet closure being called.
    /// Note too that if the future has already been sent, this closure is not called.
    ///
    /// - Parameter closure: The code to be executed
    public func onSet(_ closure: @escaping () -> Void) {
        onContentSet = { (_,_) in
            closure()
        }
    }
    
    /// Closure called right after content is set, without waiting the then closure.
    /// Multiple calls to this method are discouraged, resulting with only one onContentSet closure being called.
    /// Note too that if the future has already been sent, this closure is not called.
    ///
    /// - Parameter closure: The code to be executed
    public func onSet(_ closure: @escaping (inout T?, inout Error?) -> Void) {
        onContentSet = closure
    }
    
    /// Then closure executed in the given queue
    ///
    /// - Parameter queue: The dispatch queue to call the then closure
    /// - Returns: The self instance
    @discardableResult
    public func inQueue(_ queue: DispatchQueue) -> Future<T> {
        self.queue = queue
        return self
    }
    
    /// Then closure executed in the main queue
    ///
    /// - Returns: The self instance
    @discardableResult
    public func inMainQueue() -> Future<T> {
        return self.inQueue(DispatchQueue.main)
    }
    
    /// Synchronous then
    public func then() -> Result {
        switch state {
        case .waitingThen:
            if !reactive {
                state = .sent
            }
            return result!
        case .blank:
            semaphore = DispatchSemaphore(value: 0)
            DispatchSemaphore.wait(semaphore!)()
            return then()
        case .waitingContent:
            fatalError(FutureError.thenAlreadySet.localizedDescription)
        case .sent:
            fatalError(FutureError.alreadySent.localizedDescription)
        }
    }
    
    /// Then closure: delivers the optional value or the error
    public func then(success: @escaping (T?) -> Void,
                     failure: @escaping (Error) -> Void) {
        if !reactive {
            if self.success != nil || self.failure != nil {
                fatalError(FutureError.thenAlreadySet.localizedDescription)
            }
        }
        self.success = success
        self.failure = failure
        update()
    }
    
    /// Completes the future (if not completed yet)
    public func complete() {
        if state != .sent {
            state = .sent
            self.success = nil
            self.failure = nil
            for observer in observers.allObjects {
                (observer as! FutureObserver).didCompleteFuture(self)
            }
        }
    }
    
    /// Adds an observer
    public func add(_ observer: FutureObserver) {
        observers.add(observer)
        if state == .sent {
            observer.didCompleteFuture(self)
        }
    }
    
    /// Removes an observer
    public func remove(_ observer: FutureObserver) {
        observers.remove(observer)
    }

    private func update() {
        switch state {
        case .sent:
            fatalError(FutureError.alreadySent.localizedDescription)
        case .blank:
            // Waiting for either the result, or the then closure
            if result != nil {
                state = .waitingThen
                if let semaphore = semaphore {
                    DispatchSemaphore.signal(semaphore)()
                }
            } else if (success != nil) {
                state = .waitingContent
            }
        case .waitingThen:
            if success != nil {
                send()
                if !reactive {
                    state = .sent
                }
            }
        case .waitingContent:
            if result != nil {
                send()
                if !reactive {
                    state = .sent
                }
            }
        }
    }
    
    private func send() {
        if let queue = queue {
            let success = self.success!
            let failure = self.failure!
            let result = self.result!
            queue.async {
                switch result {
                case .error(let error):
                    failure(error)
                case .value(let value):
                    success(value)
                case .empty:
                    success(nil)
                }
            }
        } else {
            switch result! {
            case .error(let error):
                failure!(error)
            case .value(let value):
                success!(value)
            case .empty:
                success!(nil)
            }
        }
        for observer in observers.allObjects {
            (observer as! FutureObserver).didCompleteFuture(self)
        }
        if !reactive {
            self.success = nil
            self.failure = nil
        }
    }
}

// MARK: Future Funtional Programming

/// Functional programming extension
public extension Future {
    /// Mappes the value and return a new future with the value mapped
    public func map<K>(_ transform: @escaping (T) -> K) -> Future<K> {
        return Future<K>(reactive: self.reactive) { future in
            self.then(success: { (value) in
                if value != nil {
                    future.set(transform(value!))
                } else {
                    future.set(nil)
                }
            }, failure: { (error) in
                future.set(error)
            })
        }
    }
    
    /// Mappes the error and return a new future with the error mapped
    public func mapError(_ transform: @escaping (Error) -> Error) -> Future<T> {
        return Future(reactive: self.reactive) { future in
            self.then(success: { (value) in
                future.set(value)
            }, failure: { (error) in
                future.set(transform(error))
            })
        }
    }
    
    /// Intercepts the value if success and returns a new future of a mapped type to be chained
    public func flatMap<K>(_ closure: @escaping (T) -> Future<K>) -> Future<K> {
        return Future<K>(reactive: self.reactive) { future in
            self.then(success: { (value) in
                if let value = value {
                    future.set(closure(value))
                } else {
                    future.set(nil)
                }
            }, failure: { (error) in
                future.set(error)
            })
        }
    }
    
    /// Intercepts the error (if available) and returns a new future of type T
    public func recover(_ closure: @escaping (Error) -> Future<T>) -> Future<T> {
        return Future(reactive: self.reactive) { future in
            self.then(success: { (value) in
                future.set(value)
            }, failure: { (error) in
                future.set(closure(error))
            })
        }
    }
    
    /// Intercepts the then closure and returns a future containing the same result
    public func andThen(success: @escaping (T?) -> Void = { _ in },
                        failure: @escaping (Error) -> Void = { _ in }) -> Future<T> {
        return Future(reactive: self.reactive) { future in
            self.then(success: { (value) in
                success(value)
                future.set(value)
            }, failure: { (error) in
                failure(error)
                future.set(error)
            })
        }
    }
    
    @discardableResult
    public func onCompletion(_ closure: @escaping () -> Void) -> Future<T> {
        return Future(reactive: self.reactive) { future in
            self.then(success: { (value) in
                closure()
                future.set(value)
            }, failure: { (error) in
                closure()
                future.set(error)
            })
        }
    }
    
    /// Filters the value and allows to exchange it in an error
    public func filter(_ closure: @escaping (T?) -> Error?) -> Future<T> {
        return Future(reactive: self.reactive) { future in
            self.then(success: { value in
                if let error = closure(value) {
                    future.set(error)
                } else {
                    future.set(value)
                }
            }, failure: { error in
                future.set(error)
            })
        }
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K>(_ futureK: Future<K>) -> Future<(T?,K?)> {
        return self.flatMap { valueT in
            return futureK.map({ valueK in
                return (valueT, valueK)
            })
        }
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K,L>(_ futureK: Future<K>, _ futureL: Future<L>) -> Future<(T?,K?,L?)> {
        return self.zip(futureK).flatMap { valueTK in
            return futureL.map({ valueL in
                return (valueTK.0, valueTK.1, valueL)
            })
        }
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K,L,M>(_ futureK: Future<K>, _ futureL: Future<L>, _ futureM: Future<M>) -> Future<(T?,K?,L?,M?)> {
        return self.zip(futureK, futureL).flatMap { valueTKL in
            return futureM.map({ valueM in
                return (valueTKL.0, valueTKL.1, valueTKL.2, valueM)
            })
        }
    }
}

// MARK: Timing extensions

public extension Future {
    /// Adds a delay to the then call
    public func withDelay(_ interval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Future<T> {
        return Future(reactive: self.reactive) { future in
            queue.asyncAfter(deadline: .now() + interval) {
                self.then(success: { (value) in
                    future.set(value)
                }, failure: { (error) in
                    future.set(error)
                })
            }
        }
    }
    
    /// Calls the then block after the given deadline
    public func after(_ deadline: DispatchTime, queue: DispatchQueue = DispatchQueue.main) -> Future<T> {
        return Future(reactive: self.reactive) { future in
            queue.asyncAfter(deadline: deadline) {
                self.then(success: { (value) in
                    future.set(value)
                }, failure: { (error) in
                    future.set(error)
                })
            }
        }
    }
    
    /// Ensures the future is called after the given date.
    /// If the date is earlier than now, nothing happens.
    public func after(_ date: Date) -> Future<T> {
        let interval = date.timeIntervalSince(Date())
        if interval < 0 {
            return self
        } else {
            return withDelay(interval)
        }
    }
}

/// Operator + overriding
public func +<T,K>(left: Future<T>, right: Future<K>) -> Future<(T?,K?)> {
    return left.zip(right)
}

precedencegroup MapPrecedance {
    associativity: left
}
infix operator <^> : MapPrecedance

/// Map operator
public func <^><T,K>(future: Future<T>, map: @escaping (T) -> K) -> Future<K> {
    return future.map { value in map(value) }
}

/// To String extension
extension Future : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch state {
        case .blank:
            return "Empty future. Waiting for value, error and then closure."
        case .waitingThen:
            switch result! {
            case .error(let error):
                return "Future waiting for then closure and error set to: \(error)"
            case .value(let value):
                return "Future waiting for then closure and value set to: \(value)"
            case .empty:
                return "Future waiting for then closure and value set to nil."
            }
        case .waitingContent:
            return "Future then closure set. Waiting for value or error."
        case .sent:
            switch result! {
            case .error(let error):
                return "Future sent with error: \(error)"
            case .value(let value):
                return "Future sent with value: \(value)"
            case .empty:
                return "Future sent with nil value."
            }
        }
    }
    public var debugDescription: String {
        return description
    }
}
