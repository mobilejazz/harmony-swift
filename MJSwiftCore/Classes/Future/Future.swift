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

///
/// Future class. Wrapper of a future value of generic type T or an error.
///
public class Future<T> {
    
    private enum InternalError: Error {
        case contentAlreadySet
        case thenAlreadySet
        case alreadySent
        case notReactive
        case missingLambda
        
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
            case .missingLambda:
                return "Future cannot be sent as the then clousre hasn't been defined"
            }
        }
    }
    
    // The future nesting level.
    //   - 0 if the user-created future
    //   - Increase 1 for each functional-programming-method generated future
    public internal(set) var nestingLevel : Int = 0
    
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
    /// - value: a value was provided
    /// - error: an error was provided
    public indirect enum Result {
        case value(T)
        case error(Error)
    }
    
    /// The future result
    public private(set) var result : Result? = nil
    
    /// Defines if the future is reactive or not.
    public private(set) var reactive : Bool
    
    // Private variables
    private var onContentSet: ((inout T?, inout Error?) -> Void)?
    private var queue: DispatchQueue?
    private var semaphore: DispatchSemaphore?
    private let lock = NSLock()
    private var success: ((_ value: T) -> Void)?
    private var failure: ((_ error: Error) -> Void)?
    
    private func lock(_ closure: () -> Void) {
        lock.lock()
        closure()
        lock.unlock()
    }
    
    /// Returns a hub associated to the current future
    public private(set) lazy var hub = FutureHub<T>(self)
    
    /// Default initializer
    public init(reactive: Bool = false) {
        self.reactive = reactive
    }
    
    /// Value initializer
    public init(_ value: T, reactive: Bool = false) {
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
    public init(reactive: Bool = false, _ closure: (Future<T>) throws -> Void) {
        self.reactive = reactive
        do {
            try closure(self)
        } catch (let error) {
            set(error)
        }
    }
    
    /// Future initializer
    public convenience init(reactive: Bool = false, _ closure: () throws -> T) {
        do {
            let value = try closure()
            self.init(value, reactive: reactive)
        } catch (let error) {
            self.init(error, reactive: reactive)
        }
    }
    
    /// Creates a new future from self
    public func toFuture() -> Future<T> {
        return Future(self)
    }
    
    /// Configures the reactive state as the given future
    internal func mimic(_ future: Future<T>) {
        reactive = future.reactive
    }
    
    /// Sets the future value
    public func set(_ value: T) {
        set(value: value, error: nil)
    }
    
    /// Sets the future error
    public func set(_ error: Error) {
        set(value: nil, error: error)
    }
    
    /// Sets the future with another future
    public func set(_ future: Future<T>, copyReactiveState: Bool = true) {
        if copyReactiveState {
            reactive = future.reactive
        }
        future.then(success: { value in
            self.set(value)
        }, failure: { error in
            self.set(error)
        })
    }
    
    /// Sets the future with a value if not error. Either the value or the error must be provided, otherwise a crash will happen.
    /// Note: error is prioritary, and if not error the value will be used.
    public func set(value: T?, error: Error?) {
        if !reactive {
            if result != nil {
                fatalError(InternalError.contentAlreadySet.localizedDescription)
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
        
        lock() {
            if let error = error {
                result = .error(error)
            } else {
                result = .value(value!)
            }
            
            if success != nil || failure != nil {
                // Resolve the then closure
                send()
                if !reactive {
                    state = .sent
                }
            } else {
                state = .waitingThen
                if let semaphore = semaphore {
                    semaphore.signal()
                }
            }
        }
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
    
    /// Removes the custom defined queue
    ///
    /// - Returns: The self instance
    public func inOriginalQueue() -> Future<T> {
        self.queue = nil
        return self
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
            fatalError(InternalError.thenAlreadySet.localizedDescription)
        case .sent:
            fatalError(InternalError.alreadySent.localizedDescription)
        }
    }
    
    /// Then closure: delivers the value or the error
    public func then(success: @escaping (T) -> Void = { _ in },
                     failure: @escaping (Error) -> Void = { _ in }) {
        if !reactive {
            if self.success != nil || self.failure != nil {
                fatalError(InternalError.thenAlreadySet.localizedDescription)
            }
        }
        
        lock() {
            self.success = success
            self.failure = failure
            if result != nil {
                send()
                if !reactive {
                    state = .sent
                }
            } else {
                state = .waitingContent
            }
        }
    }
    
    /// Defines the success closure. If already defined, it creates a new future, chain it and defines the new then closure.
    @discardableResult
    public func then(_ success: @escaping (T) -> Void)  -> Future<T> {
        if self.success != nil {
            let future = Future(self)
            future.then(success)
            return future
        }
        
        lock() {
            self.success = success
            if result != nil {
                send()
                if !reactive {
                    state = .sent
                }
            } else {
                state = .waitingContent
            }
        }
        return self
    }
    
    /// Defines the failure closure. If already defined, it creates a new future, chain it and defines the new then closure.
    @discardableResult
    public func fail(_ failure: @escaping (Error) -> Void) -> Future<T> {
        if self.failure != nil {
            let future = Future(self)
            future.fail(failure)
            return future
        }
        
        lock() {
            self.failure = failure
            if result != nil {
                send()
                if !reactive {
                    state = .sent
                }
            } else {
                state = .waitingContent
            }
        }
        return self
    }
    
    /// Completes the future (if not completed yet)
    public func complete() {
        lock() {
            if state != .sent {
                state = .sent
                success = nil
                failure = nil
            }
        }
    }
    
    private func send() {
        switch result! {
        case .error(let error):
            guard let failure = failure else {
                print(InternalError.missingLambda.localizedDescription)
                return
            }
            if let queue = queue {
                queue.async {
                    failure(error)
                }
            } else {
                failure(error)
            }
        case .value(let value):
            guard let success = success else {
                print(InternalError.missingLambda.localizedDescription)
                return
            }
            if let queue = queue {
                queue.async {
                    success(value)
                }
                
            } else {
                success(value)
            }
        }
        if !reactive {
            self.success = nil
            self.failure = nil
        }
    }
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
            }
        case .waitingContent:
            return "Future then closure set. Waiting for value or error."
        case .sent:
            switch result! {
            case .error(let error):
                return "Future sent with error: \(error)"
            case .value(let value):
                return "Future sent with value: \(value)"
            }
        }
    }
    public var debugDescription: String {
        return description + "(nesting level: \(nestingLevel))"
    }
}
