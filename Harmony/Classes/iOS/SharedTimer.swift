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

import UIKit

/// The observer protocol
public protocol SharedTimerObserver {
    /// Timer firing callback
    ///
    /// - Parameters:
    ///   - timer: The SharedTimer instance
    ///   - date: The firing date
    func didFire(timer: SharedTimer, date: Date)
}

///
/// A SharedTimer is a timer that can be observed by multiple objects.
/// If no observers, the timer stops and runs again upon a new observer is added.
///
public class SharedTimer {
    
    private var timer : Timer? = nil
    private let observers = NSHashTable<AnyObject>.weakObjects()
    private var invalidated : Bool = false
    
    /// The timer interval
    public let interval : Double
    /// The timer repeating configuration
    public let repeats : Bool
    
    /// Returns true if there are observers tracking the timer, otherwise false.
    public var isActive : Bool {
        get {
            guard let timer = timer else {
                return false
            }
            return timer.isValid
        }
    }
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - interval: The time interval
    ///   - repeats: The repetition configuration. Default value is false
    ///   - observers: An observer array. Note that observers can be also added later.
    public init (interval: Double, repeats: Bool = false, observers: [SharedTimerObserver] = []) {
        self.interval = interval
        self.repeats = repeats
        for observer in observers {
            self.observers.add(observer as AnyObject)
        }
        if !repeats {
            startTimer()
        }
    }
    
    /// Invalidates the timer. Once invalidated, the instance can't be used anymore.
    public func invalidate() {
        ScopeLock(self).sync {
            invalidated = true
            if let timer = timer {
                timer.invalidate()
            }
            timer = nil
        }
    }
    
    /// Adds an observer.
    /// Note that if the timer is repeating, upon adding the first observer the timer will start running.
    ///
    /// - Parameter observer: An observer
    public func add(_ observer: SharedTimerObserver) {
        ScopeLock(self).sync {
            let count = observers.count
            observers.add(observer as AnyObject)
            if count == 0 && observers.count > 0 && repeats {
                startTimer()
            }
        }
    }
    
    
    /// Removes an observer
    /// Note that if the timer is repeating, upon removing the last observer the timer will stop running.
    ///
    /// - Parameter observer: An observer
    public func remove(_ observer: SharedTimerObserver) {
        ScopeLock(self).sync {
            observers.remove(observer as AnyObject)
            if observers.count == 0 && repeats {
                stopTimer()
            }
        }
    }
    
    private func startTimer() {
        if invalidated {
            return
        }
    
        if #available(iOS 10.0, *) {
            timer = Timer(timeInterval: interval, repeats: repeats) { timer in
                let observers = self.observers.allObjects as! [SharedTimerObserver]
                for observer in observers {
                    observer.didFire(timer: self, date: timer.fireDate)
                }
            }
        } else {
            
            let date = Date(timeInterval: interval, since: Date())
            timer = Timer(fireAt: date, interval: interval, target: self, selector: #selector(fire(timer:)), userInfo: nil, repeats: repeats)
        }
        
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.tracking)
    }
    
    private func stopTimer() {
        invalidate()
    }
    
    @available(iOS, deprecated:10.0, message: "")
    @objc private func fire(timer: Timer) {
        let observers = self.observers.allObjects as! [SharedTimerObserver]
        for observer in observers {
            observer.didFire(timer: self, date: timer.fireDate)
        }
    }
}
