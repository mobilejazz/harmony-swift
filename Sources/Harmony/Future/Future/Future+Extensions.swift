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
import CoreGraphics

// ------------ Basic Foundation Types ------------ //

// MARK: Collections

public extension Array {
    func toFuture() -> Future<[Element]> {
        return Future(self)
    }
}

public extension Dictionary {
    func toFuture() -> Future<[Key:Value]> {
        return Future(self)
    }
}

public extension Set {
    func toFuture() -> Future<Set<Element>> {
        return Future(self)
    }
}

public extension IndexPath {
    func toFuture() -> Future<IndexPath> {
        return Future(self)
    }
}

public extension IndexSet {
    func toFuture() -> Future<IndexSet> {
        return Future(self)
    }
}

public extension NSCountedSet {
    func toFuture() -> Future<NSCountedSet> {
        return Future(self)
    }
}

public extension NSOrderedSet {
    func toFuture() -> Future<NSOrderedSet> {
        return Future(self)
    }
}

public extension NSMutableOrderedSet {
    func toFuture() -> Future<NSMutableOrderedSet> {
        return Future(self)
    }
}

public extension NSPurgeableData {
    func toFuture() -> Future<NSPurgeableData> {
        return Future(self)
    }
}

public extension NSPointerArray {
    func toFuture() -> Future<NSPointerArray> {
        return Future(self)
    }
}

public extension NSNull {
    func toFuture() -> Future<NSNull> {
        return Future(self)
    }
}

// MARK: Strings and Text

public extension String {
    func toFuture() -> Future<String> {
        return Future(self)
    }
}

public extension NSAttributedString {
    func toFuture() -> Future<NSAttributedString> {
        return Future(self)
    }
}

public extension NSMutableAttributedString {
    func toFuture() -> Future<NSMutableAttributedString> {
        return Future(self)
    }
}

public extension CharacterSet {
    func toFuture() -> Future<CharacterSet> {
        return Future(self)
    }
}

// ------------ Number, Data and Basic Values ------------ //

// MARK: Numbers

public extension Bool {
    func toFuture() -> Future<Bool> {
        return Future(self)
    }
}

public extension UInt {
    func toFuture() -> Future<UInt> {
        return Future(self)
    }
}

public extension Int {
    func toFuture() -> Future<Int> {
        return Future(self)
    }
}

public extension Decimal {
    func toFuture() -> Future<Decimal> {
        return Future(self)
    }
}

public extension Float {
    func toFuture() -> Future<Float> {
        return Future(self)
    }
}

public extension Double {
    func toFuture() -> Future<Double> {
        return Future(self)
    }
}

public extension NumberFormatter {
    func toFuture() -> Future<NumberFormatter> {
        return Future(self)
    }
}

// MARK: Binary Data

public extension Data {
    func toFuture() -> Future<Data> {
        return Future(self)
    }
}

// MARK: URLs

public extension URL {
    func toFuture() -> Future<URL> {
        return Future(self)
    }
}

public extension URLComponents {
    func toFuture() -> Future<URLComponents> {
        return Future(self)
    }
}

public extension URLQueryItem {
    func toFuture() -> Future<URLQueryItem> {
        return Future(self)
    }
}

// MARK: Unique Identifiers

public extension UUID {
    func toFuture() -> Future<UUID> {
        return Future(self)
    }
}

// MARK: Geometry

public extension CGFloat {
    func toFuture() -> Future<CGFloat> {
        return Future(self)
    }
}

public extension CGAffineTransform {
    func toFuture() -> Future<CGAffineTransform> {
        return Future(self)
    }
}

// MARK: Ranges

public extension NSRange {
    func toFuture() -> Future<NSRange> {
        return Future(self)
    }
}

// ------------ Dates and Times ------------ //

// MARK: Dates

public extension Date {
    func toFuture() -> Future<Date> {
        return Future(self)
    }
}

@available(iOS 10.0, *)
public extension DateInterval {
    func toFuture() -> Future<DateInterval> {
        return Future(self)
    }
}

public extension DateComponents {
    func toFuture() -> Future<DateComponents> {
        return Future(self)
    }
}

public extension Calendar {
    func toFuture() -> Future<Calendar> {
        return Future(self)
    }
}

public extension TimeZone {
    func toFuture() -> Future<TimeZone> {
        return Future(self)
    }
}

// MARK: Date Formatting

public extension DateFormatter {
    func toFuture() -> Future<DateFormatter> {
        return Future(self)
    }
}

public extension DateComponentsFormatter {
    func toFuture() -> Future<DateComponentsFormatter> {
        return Future(self)
    }
}

public extension DateIntervalFormatter {
    func toFuture() -> Future<DateIntervalFormatter> {
        return Future(self)
    }
}

@available(iOS 10.0, *)
public extension ISO8601DateFormatter {
    func toFuture() -> Future<ISO8601DateFormatter> {
        return Future(self)
    }
}

// MARK: Locale

public extension Locale {
    func toFuture() -> Future<Locale> {
        return Future(self)
    }
}

// ------------ Filtering and Sorting ------------ //

// MARK: Filtering

public extension NSPredicate {
    func toFuture() -> Future<NSPredicate> {
        return Future(self)
    }
}

// MARK: Sorting

public extension NSSortDescriptor {
    func toFuture() -> Future<NSSortDescriptor> {
        return Future(self)
    }
}
