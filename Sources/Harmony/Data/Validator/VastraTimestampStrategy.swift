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

    fileprivate func toSeconds() -> TimeInterval? {
        switch self {
        case let .seconds(value):
            return Double(value)
        case let .minutes(value):
            return Double(value * 60)
        case let .hours(value):
            return Double(value * 3600)
        case let .days(value):
            return Double(value * 86400)
        case let .weeks(value):
            return Double(value * 604800)
        case .never:
            return nil
        }
    }
}

/// Objects that will be validated using the VastraTimestampStrategy must implement this protocol.
public protocol VastraTimestampStrategyDataSource {
    var lastUpdate: Date? { get }
    func expiryTimeInterval() -> Time
}

/// The strategy will measure the elapsed timeinterval from the `lastUpdate` to the current time.
///
/// - If the elapsed timeinterval is smaller than expiryTimeInterval: The object will be considered valid (.Valid)
/// - If the elapsed timeinterval is greater than or equal to expiryTimeInterval: The object will be considered invalid (.Invalid)
/// - If there is no a lastUpdate date, the strategy won't decide object validity (.Unknown)
public class VastraTimestampStrategy: VastraStrategy {
    public init() {}

    public func isObjectValid<T>(_ object: T) -> VastraStrategyResult {
        let lastUpdate = (object as! VastraTimestampStrategyDataSource).lastUpdate
        if lastUpdate == nil {
            return .unknown
        }

        let expiryTime = (object as! VastraTimestampStrategyDataSource).expiryTimeInterval()
        let diff = Date().timeIntervalSince(lastUpdate!)

        guard let seconds = expiryTime.toSeconds() else {
            return .invalid
        }

        if diff < seconds {
            return .valid
        } else {
            return .invalid
        }
    }
}
