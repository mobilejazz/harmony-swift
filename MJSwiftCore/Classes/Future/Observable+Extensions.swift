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
    public func toObservable() -> Observable<[Element]> {
        return Observable(self)
    }
}

public extension Dictionary {
    public func toObservable() -> Observable<[Key:Value]> {
        return Observable(self)
    }
}

public extension Set {
    public func toObservable() -> Observable<Set<Element>> {
        return Observable(self)
    }
}

public extension IndexPath {
    public func toObservable() -> Observable<IndexPath> {
        return Observable(self)
    }
}

public extension IndexSet {
    public func toObservable() -> Observable<IndexSet> {
        return Observable(self)
    }
}

public extension NSCountedSet {
    public func toObservable() -> Observable<NSCountedSet> {
        return Observable(self)
    }
}

public extension NSOrderedSet {
    public func toObservable() -> Observable<NSOrderedSet> {
        return Observable(self)
    }
}

public extension NSMutableOrderedSet {
    public func toObservable() -> Observable<NSMutableOrderedSet> {
        return Observable(self)
    }
}

public extension NSPurgeableData {
    public func toObservable() -> Observable<NSPurgeableData> {
        return Observable(self)
    }
}

public extension NSPointerArray {
    public func toObservable() -> Observable<NSPointerArray> {
        return Observable(self)
    }
}

public extension NSNull {
    public func toObservable() -> Observable<NSNull> {
        return Observable(self)
    }
}

// MARK: Strings and Text

public extension String {
    public func toObservable() -> Observable<String> {
        return Observable(self)
    }
}

public extension NSAttributedString {
    public func toObservable() -> Observable<NSAttributedString> {
        return Observable(self)
    }
}

public extension NSMutableAttributedString {
    public func toObservable() -> Observable<NSMutableAttributedString> {
        return Observable(self)
    }
}

public extension CharacterSet {
    public func toObservable() -> Observable<CharacterSet> {
        return Observable(self)
    }
}

// ------------ Number, Data and Basic Values ------------ //

// MARK: Numbers

public extension Bool {
    public func toObservable() -> Observable<Bool> {
        return Observable(self)
    }
}

public extension UInt {
    public func toObservable() -> Observable<UInt> {
        return Observable(self)
    }
}

public extension Int {
    public func toObservable() -> Observable<Int> {
        return Observable(self)
    }
}

public extension Decimal {
    public func toObservable() -> Observable<Decimal> {
        return Observable(self)
    }
}

public extension Float {
    public func toObservable() -> Observable<Float> {
        return Observable(self)
    }
}

public extension Double {
    public func toObservable() -> Observable<Double> {
        return Observable(self)
    }
}

public extension NumberFormatter {
    public func toObservable() -> Observable<NumberFormatter> {
        return Observable(self)
    }
}

// MARK: Binary Data

public extension Data {
    public func toObservable() -> Observable<Data> {
        return Observable(self)
    }
}

// MARK: URLs

public extension URL {
    public func toObservable() -> Observable<URL> {
        return Observable(self)
    }
}

public extension URLComponents {
    public func toObservable() -> Observable<URLComponents> {
        return Observable(self)
    }
}

public extension URLQueryItem {
    public func toObservable() -> Observable<URLQueryItem> {
        return Observable(self)
    }
}

// MARK: Unique Identifiers

public extension UUID {
    public func toObservable() -> Observable<UUID> {
        return Observable(self)
    }
}

// MARK: Geometry

public extension CGFloat {
    public func toObservable() -> Observable<CGFloat> {
        return Observable(self)
    }
}

public extension CGAffineTransform {
    public func toObservable() -> Observable<CGAffineTransform> {
        return Observable(self)
    }
}

// MARK: Ranges

public extension NSRange {
    public func toObservable() -> Observable<NSRange> {
        return Observable(self)
    }
}

// ------------ Dates and Times ------------ //

// MARK: Dates

public extension Date {
    public func toObservable() -> Observable<Date> {
        return Observable(self)
    }
}

@available(iOS 10.0, *)
public extension DateInterval {
    public func toObservable() -> Observable<DateInterval> {
        return Observable(self)
    }
}

public extension DateComponents {
    public func toObservable() -> Observable<DateComponents> {
        return Observable(self)
    }
}

public extension Calendar {
    public func toObservable() -> Observable<Calendar> {
        return Observable(self)
    }
}

public extension TimeZone {
    public func toObservable() -> Observable<TimeZone> {
        return Observable(self)
    }
}

// MARK: Date Formatting

public extension DateFormatter {
    public func toObservable() -> Observable<DateFormatter> {
        return Observable(self)
    }
}

public extension DateComponentsFormatter {
    public func toObservable() -> Observable<DateComponentsFormatter> {
        return Observable(self)
    }
}

public extension DateIntervalFormatter {
    public func toObservable() -> Observable<DateIntervalFormatter> {
        return Observable(self)
    }
}

@available(iOS 10.0, *)
public extension ISO8601DateFormatter {
    public func toObservable() -> Observable<ISO8601DateFormatter> {
        return Observable(self)
    }
}

// MARK: Locale

public extension Locale {
    public func toObservable() -> Observable<Locale> {
        return Observable(self)
    }
}

// ------------ Filtering and Sorting ------------ //

// MARK: Filtering

public extension NSPredicate {
    public func toObservable() -> Observable<NSPredicate> {
        return Observable(self)
    }
}

// MARK: Sorting

public extension NSSortDescriptor {
    public func toObservable() -> Observable<NSSortDescriptor> {
        return Observable(self)
    }
}
