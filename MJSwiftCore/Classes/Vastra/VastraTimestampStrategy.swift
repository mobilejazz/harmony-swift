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

public enum Time {
    case seconds(Int)
    case minutes(Int)
    case hours(Int)
    case days(Int)
    case weeks(Int)
    case never
}

/// Objects that will be validated using the VastraTimestampStrategy must implement this protocol.
public protocol VastraTimestampStrategyDataSource {
    var  lastUpdate : Date? {get}
    func expiryTimeInterval() -> Time
}

/// The strategy will measure the elapsed timeinterval from the `lastUpdate` to the current time.
///
/// - If the elapsed timeinterval is smaller than expiryTimeInterval: The object will be considered valid (.Valid)
/// - If the elapsed timeinterval is greater than or equal to expiryTimeInterval: The object will be considered invalid (.Invalid)
/// - If there is no a lastUpdate date, the strategy won't decide object validity (.Unknown)
public class VastraTimestampStrategy: VastraStrategy {
    public init() { }
    
    public func isObjectValid<T>(_ object: T) -> VastraStrategyResult {
        let lastUpdate = (object as! VastraTimestampStrategyDataSource).lastUpdate
        if lastUpdate == nil {
            return .Unknown
        }
        
        let expiryTime = (object as! VastraTimestampStrategyDataSource).expiryTimeInterval()
        let diff = Date().timeIntervalSince(lastUpdate!)
        
        var seconds  = 0
        switch (expiryTime) {
        case let .seconds(value):
            seconds = value
        case let .minutes(value):
            seconds = value * 60
        case let .hours(value):
            seconds = value * 3600
        case let .days(value):
            seconds = value * 86400
        case let .weeks(value):
            seconds = value * 604800
        case .never:
            return .Invalid
        }
        
        if diff < Double(seconds) {
            return .Valid
        } else {
            return .Invalid
        }
    }
}
