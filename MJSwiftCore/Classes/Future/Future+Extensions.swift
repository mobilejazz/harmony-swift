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

// ------------ Basic Foundation Types ------------ //

// MARK: Collections

public extension Array {
    public func toFuture() -> Future<[Element]> {
        return Future(self)
    }
}

public extension Dictionary {
    public func toFuture() -> Future<[Key:Value]> {
        return Future(self)
    }
}

public extension Set {
    public func toFuture() -> Future<Set<Element>> {
        return Future(self)
    }
}

public extension IndexPath {
    public func toFuture() -> Future<IndexPath> {
        return Future(self)
    }
}

public extension IndexSet {
    public func toFuture() -> Future<IndexSet> {
        return Future(self)
    }
}

public extension NSCountedSet {
    public func toFuture() -> Future<NSCountedSet> {
        return Future(self)
    }
}

public extension NSOrderedSet {
    public func toFuture() -> Future<NSOrderedSet> {
        return Future(self)
    }
}

public extension NSMutableOrderedSet {
    public func toFuture() -> Future<NSMutableOrderedSet> {
        return Future(self)
    }
}

public extension NSPurgeableData {
    public func toFuture() -> Future<NSPurgeableData> {
        return Future(self)
    }
}

public extension NSPointerArray {
    public func toFuture() -> Future<NSPointerArray> {
        return Future(self)
    }
}

public extension NSNull {
    public func toFuture() -> Future<NSNull> {
        return Future(self)
    }
}

// MARK: Strings and Text

public extension String {
    public func toFuture() -> Future<String> {
        return Future(self)
    }
}

public extension NSAttributedString {
    public func toFuture() -> Future<NSAttributedString> {
        return Future(self)
    }
}

public extension NSMutableAttributedString {
    public func toFuture() -> Future<NSMutableAttributedString> {
        return Future(self)
    }
}

public extension CharacterSet {
    public func toFuture() -> Future<CharacterSet> {
        return Future(self)
    }
}

// ------------ Number, Data and Basic Values ------------ //

// MARK: Numbers

public extension Bool {
    public func toFuture() -> Future<Bool> {
        return Future(self)
    }
}

public extension UInt {
    public func toFuture() -> Future<UInt> {
        return Future(self)
    }
}

public extension Int {
    public func toFuture() -> Future<Int> {
        return Future(self)
    }
}

public extension Decimal {
    public func toFuture() -> Future<Decimal> {
        return Future(self)
    }
}

public extension Float {
    public func toFuture() -> Future<Float> {
        return Future(self)
    }
}

public extension Double {
    public func toFuture() -> Future<Double> {
        return Future(self)
    }
}

public extension NumberFormatter {
    public func toFuture() -> Future<NumberFormatter> {
        return Future(self)
    }
}

// MARK: Binary Data

public extension Data {
    public func toFuture() -> Future<Data> {
        return Future(self)
    }
}

// MARK: URLs

public extension URL {
    public func toFuture() -> Future<URL> {
        return Future(self)
    }
}

public extension URLComponents {
    public func toFuture() -> Future<URLComponents> {
        return Future(self)
    }
}

public extension URLQueryItem {
    public func toFuture() -> Future<URLQueryItem> {
        return Future(self)
    }
}

// MARK: Unique Identifiers

public extension UUID {
    public func toFuture() -> Future<UUID> {
        return Future(self)
    }
}

// MARK: Geometry

public extension CGFloat {
    public func toFuture() -> Future<CGFloat> {
        return Future(self)
    }
}

public extension CGAffineTransform {
    public func toFuture() -> Future<CGAffineTransform> {
        return Future(self)
    }
}

// MARK: Ranges

public extension NSRange {
    public func toFuture() -> Future<NSRange> {
        return Future(self)
    }
}

// ------------ Dates and Times ------------ //

// MARK: Dates

public extension Date {
    public func toFuture() -> Future<Date> {
        return Future(self)
    }
}

@available(iOS 10.0, *)
public extension DateInterval {
    public func toFuture() -> Future<DateInterval> {
        return Future(self)
    }
}

public extension DateComponents {
    public func toFuture() -> Future<DateComponents> {
        return Future(self)
    }
}

public extension Calendar {
    public func toFuture() -> Future<Calendar> {
        return Future(self)
    }
}

public extension TimeZone {
    public func toFuture() -> Future<TimeZone> {
        return Future(self)
    }
}

// MARK: Date Formatting

public extension DateFormatter {
    public func toFuture() -> Future<DateFormatter> {
        return Future(self)
    }
}

public extension DateComponentsFormatter {
    public func toFuture() -> Future<DateComponentsFormatter> {
        return Future(self)
    }
}

public extension DateIntervalFormatter {
    public func toFuture() -> Future<DateIntervalFormatter> {
        return Future(self)
    }
}

@available(iOS 10.0, *)
public extension ISO8601DateFormatter {
    public func toFuture() -> Future<ISO8601DateFormatter> {
        return Future(self)
    }
}

// MARK: Locale

public extension Locale {
    public func toFuture() -> Future<Locale> {
        return Future(self)
    }
}

// ------------ Filtering and Sorting ------------ //

// MARK: Filtering

public extension NSPredicate {
    public func toFuture() -> Future<NSPredicate> {
        return Future(self)
    }
}

// MARK: Sorting

public extension NSSortDescriptor {
    public func toFuture() -> Future<NSSortDescriptor> {
        return Future(self)
    }
}
