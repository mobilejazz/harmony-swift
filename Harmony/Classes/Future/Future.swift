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

fileprivate struct FutureError : Error {
    let description : String
    init(_ description: String) {
        self.description = description
    }
}

extension FutureError {
    /// Future content has already been set
    fileprivate static let thenAlreadySet = FutureError("Then already set: cannot set a new then closure once is already set.")
    
    /// Future content has already been set
    fileprivate static let alreadySent = FutureError("Future is already sent.")
    
    /// Future content has already been set
    fileprivate static let missingLambda = FutureError("Future cannot be sent as the then clousre hasn't been defined")
}

///
/// A FutureResolver resolves a Future.
///
public struct FutureResolver<T> {
    
    private var future : Future<T>
    
    /// Main initializer
    ///
    /// - Parameter future: The future to resolve
    public init(_ future: Future<T>) {
        self.future = future
    }
    
    /// Sets the future value
    public func set(_ value: T) {
        future.set(value)
    }
    
    /// Sets the future error
    public func set(_ error: Error) {
        future.set(error)
    }
    
    /// Sets the future with another future
    public func set(_ future: Future<T>) {
        self.future.set(future)
    }
    
    /// Sets the future with a value if not error. Either the value or the error must be provided, otherwise a crash will happen.
    /// Note: error is prioritary, and if not error the value will be used.
    public func set(value: T?, error: Error?) {
        future.set(value: value, error: error)
    }
}

extension FutureResolver where T==Void {
    /// Sets the future with a void value
    public func set() {
        future.set()
    }
}


///
/// Future class. Wrapper of a future value of generic type T or an error.
///
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
    /// - value: a value was provided
    /// - error: an error was provided
    public indirect enum Result {
        case value(T)
        case error(Error)
        
        /// Returns the value or throws an error if exists
        @discardableResult
        public func get() throws -> T {
            switch self {
            case .value(let v):
                return v
            case .error(let e):
                throw e
            }
        }
        
        // Returns the value or if error, returns nil and sets the error
        @discardableResult
        public func get(error: inout Error?) -> T? {
            switch self {
            case .value(let v):
                return v
            case .error(let e):
                error = e
                return nil
            }
        }
    }
    
    /// The future result. Using _ prefix as the "result" method returns synchronously the result.
    internal var _result : Result? = nil
    
    // Private variables
    private var onContentSet: ((inout T?, inout Error?) -> Void)?
    private var semaphore: DispatchSemaphore?
    private let lock = NSLock()
    private var success: ((_ value: T) -> Void)?
    private var failure: ((_ error: Error) -> Void)?
    
    /// Default initializer
    public init() { }
    
    /// Value initializer
    public init(_ value: T) {
        set(value)
    }
    
    /// Error initializer
    public init(_ error: Error) {
        set(error)
    }
    
    /// Future initializer
    public init(_ future: Future<T>) {
        set(future)
    }
    
    /// Future initializer
    public init(_ observable: Observable<T>, atEvent index: Int = 0) {
        set(observable, atEvent: index)
    }
    
    /// Future initializer
    public init(_ observable: Observable<T>, ignoreErrors: Bool = false, atEventPassingTest closure: @escaping (T) -> Bool) {
        set(observable, ignoreErrors: ignoreErrors, atEventPassingTest: closure)
    }
    
    /// Future initializer
    public init(_ closure: (FutureResolver<T>) throws -> Void) {
        do {
            let resolver = FutureResolver(self)
            try closure(resolver)
        } catch (let error) {
            set(error)
        }
    }
    
    /// Future initializer
    public convenience init(future closure: () throws -> Future<T>) {
        do {
            let future = try closure()
            self.init(future)
        } catch (let error) {
            self.init(error)
        }
    }
    
    /// Future initializer
    public convenience init(value closure: () throws -> T) {
        do {
            let value = try closure()
            self.init(value)
        } catch (let error) {
            self.init(error)
        }
    }
    
    /// Future initializer
    public convenience init(_ closure: () -> Error) {
        let error = closure()
        self.init(error)
    }
    
    /// Creates a new future from self
    public func toFuture() -> Future<T> {
        return Future(self)
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
    public func set(_ future: Future<T>) {
        future.resolve(success: { value in
            self.set(value)
        }, failure: { error in
            self.set(error)
        })
    }
    
    /// Sets the future with a given observable at the given event index
    ///
    /// - Parameters:
    ///   - observable: The incoming observable
    ///   - eventIdx: The event index to set the future. Use 0 to indicate the following event (or the eixsting one if the observer is already resolved). Default is 0.
    public func set(_ observable: Observable<T>, atEvent eventIdx: Int = 0) {
        var obs : Observable<T>? = observable.hub.subscribe()
        var idx = eventIdx
        obs!.resolve(success: { value in
            if idx == 0 {
                self.set(value)
                obs = nil
            }
            idx -= 1
        }, failure: { error in
            if idx == 0 {
                self.set(error)
                obs = nil
            }
            idx -= 1
        })
    }
    
    /// Sets the future with the given observable when the passing test results true.
    ///
    /// - Parameters:
    ///   - observable: The incoming observable
    ///   - closure: The test closure
    ///   - ignoreErrors: if true, all errors will be ignored (and the future is not resolved). Default is false.
    public func set(_ observable: Observable<T>, ignoreErrors: Bool = false, atEventPassingTest closure: @escaping (T) -> Bool) {
        var obs : Observable<T>? = observable.hub.subscribe()
        obs!.resolve(success: { value in
            if closure(value) {
                self.set(value)
                obs = nil
            }
        }, failure: { error in
            if ignoreErrors {
                self.set(error)
                obs = nil
            }
        })
    }
    
    /// Sets the future with a value if not error. Either the value or the error must be provided, otherwise a crash will happen.
    /// Note: error is prioritary, and if not error the value will be used.
    public func set(value: T?, error: Error?) {
        if _result != nil || state == .sent  {
            // Do nothing
            return
        }
        
        var value : T? = value
        var error : Error? = error
        if let onContentSet = onContentSet {
            onContentSet(&value, &error)
            self.onContentSet = nil
        }
        
        lock {
            if let error = error {
                _result = .error(error)
            } else {
                _result = .value(value!)
            }
            
            if success != nil || failure != nil {
                // Resolve the then closure
                send()
                state = .sent
            } else {
                state = .waitingThen
                if let semaphore = semaphore {
                    semaphore.signal()
                }
            }
        }
    }
    
    /// Clears the stored value and the referenced then closures.
    /// Mainly, resets the state of the future to blank.
    ///
    /// - Returns: The self instance
    @discardableResult
    public func clear() -> Future<T> {
        lock {
            _result = nil
            success = nil
            failure = nil
            state = .blank
        }
        return self
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
    
    /// Then closure: delivers the value or the error
    internal func resolve(success: @escaping (T) -> Void = { _ in },
                          failure: @escaping (Error) -> Void = { _ in }) {
        
        if self.success != nil || self.failure != nil {
            fatalError(FutureError.thenAlreadySet.description)
        }
        
        lock {
            self.success = success
            self.failure = failure
            if _result != nil {
                send()
                state = .sent
            } else {
                state = .waitingContent
            }
        }
    }
    
    /// Deliver the result syncrhonously. This method might block the calling thread.
    /// Note that the result can only be delivered once
    public var result : Result {
        get {
            switch state {
            case .waitingThen:
                state = .sent
                return _result!
            case .blank:
                semaphore = DispatchSemaphore(value: 0)
                semaphore!.wait()
                return self.result
            case .waitingContent:
                fatalError(FutureError.thenAlreadySet.description)
            case .sent:
                fatalError(FutureError.alreadySent.description)
            }
        }
    }
    
    /// Main then method to obtain the promised value.
    ///
    /// - Parameters:
    ///   - executor: An optional executor to call the then closure.
    ///   - success: The then closure.
    /// - Returns: A chained future
    @discardableResult
    public func then(_ executor: Executor = MainDirectExecutor(), _ success: @escaping (T) -> Void) -> Future<T> {
        return Future { resolver in
            resolve(success: {value in
                executor.submit {
                    success(value)
                    resolver.set(value)
                }
            }, failure: { error in
                executor.submit {
                    resolver.set(error)
                }
            })
        }
    }
    
    /// Main failure method to obtain the promised error.
    ///
    /// - Parameters:
    ///   - executor: An optional executor to call the then closure.
    ///   - failure: The fail closure.
    /// - Returns: A chained future
    @discardableResult
    public func fail(_ executor: Executor = MainDirectExecutor(), _ failure: @escaping (Error) -> Void) -> Future<T> {
        return Future { resolver in
            resolve(success: {value in
                executor.submit {
                    resolver.set(value)
                }
            }, failure: { error in
                executor.submit {
                    failure(error)
                    resolver.set(error)
                }
            })
        }
    }
    
    /// Completes the future (if not completed yet)
    public func complete() {
        lock {
            if state != .sent {
                state = .sent
                success = nil
                failure = nil
            }
        }
    }
    
    private func send() {
        switch _result! {
        case .error(let error):
            guard let failure = failure else {
                print(FutureError.missingLambda.description)
                return
            }
            failure(error)
        case .value(let value):
            guard let success = success else {
                print(FutureError.missingLambda.description)
                return
            }
            success(value)
        }
        
        self.success = nil
        self.failure = nil
    }
    
    // Private lock method
    private func lock(_ closure: () -> Void) {
        lock.lock()
        closure()
        lock.unlock()
    }
}

/// To String extension
extension Future : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch state {
        case .blank:
            return "Empty future. Waiting for value, error and then closure."
        case .waitingThen:
            switch _result! {
            case .error(let error):
                return "Future waiting for then closure with error set to: \(error)"
            case .value(let value):
                return "Future waiting for then closure with value set to: \(value)"
            }
        case .waitingContent:
            return "Future waiting for value or error."
        case .sent:
            if let result = _result {
                switch result {
                case .error(let error):
                    return "Future sent with error: \(error)"
                case .value(let value):
                    return "Future sent with value: \(value)"
                }
            } else {
                return "Future sent"
            }
        }
    }
    public var debugDescription: String {
        return description
    }
}

extension Future where T==Void {
    public func set() {
        set(Void())
    }
}

