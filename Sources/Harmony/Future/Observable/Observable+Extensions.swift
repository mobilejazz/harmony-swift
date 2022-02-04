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
    func toObservable() -> Observable<[Element]> {
        return Observable(self)
    }
}

public extension Dictionary {
    func toObservable() -> Observable<[Key:Value]> {
        return Observable(self)
    }
}

public extension Set {
    func toObservable() -> Observable<Set<Element>> {
        return Observable(self)
    }
}

public extension IndexPath {
    func toObservable() -> Observable<IndexPath> {
        return Observable(self)
    }
}

public extension IndexSet {
    func toObservable() -> Observable<IndexSet> {
        return Observable(self)
    }
}

public extension NSCountedSet {
    func toObservable() -> Observable<NSCountedSet> {
        return Observable(self)
    }
}

public extension NSOrderedSet {
    func toObservable() -> Observable<NSOrderedSet> {
        return Observable(self)
    }
}

public extension NSMutableOrderedSet {
    func toObservable() -> Observable<NSMutableOrderedSet> {
        return Observable(self)
    }
}

public extension NSPurgeableData {
    func toObservable() -> Observable<NSPurgeableData> {
        return Observable(self)
    }
}

public extension NSPointerArray {
    func toObservable() -> Observable<NSPointerArray> {
        return Observable(self)
    }
}

public extension NSNull {
    func toObservable() -> Observable<NSNull> {
        return Observable(self)
    }
}

// MARK: Strings and Text

public extension String {
    func toObservable() -> Observable<String> {
        return Observable(self)
    }
}

public extension NSAttributedString {
    func toObservable() -> Observable<NSAttributedString> {
        return Observable(self)
    }
}

public extension NSMutableAttributedString {
    func toObservable() -> Observable<NSMutableAttributedString> {
        return Observable(self)
    }
}

public extension CharacterSet {
    func toObservable() -> Observable<CharacterSet> {
        return Observable(self)
    }
}

// ------------ Number, Data and Basic Values ------------ //

// MARK: Numbers

public extension Bool {
    func toObservable() -> Observable<Bool> {
        return Observable(self)
    }
}

public extension UInt {
    func toObservable() -> Observable<UInt> {
        return Observable(self)
    }
}

public extension Int {
    func toObservable() -> Observable<Int> {
        return Observable(self)
    }
}

public extension Decimal {
    func toObservable() -> Observable<Decimal> {
        return Observable(self)
    }
}

public extension Float {
    func toObservable() -> Observable<Float> {
        return Observable(self)
    }
}

public extension Double {
    func toObservable() -> Observable<Double> {
        return Observable(self)
    }
}

public extension NumberFormatter {
    func toObservable() -> Observable<NumberFormatter> {
        return Observable(self)
    }
}

// MARK: Binary Data

public extension Data {
    func toObservable() -> Observable<Data> {
        return Observable(self)
    }
}

// MARK: URLs

public extension URL {
    func toObservable() -> Observable<URL> {
        return Observable(self)
    }
}

public extension URLComponents {
    func toObservable() -> Observable<URLComponents> {
        return Observable(self)
    }
}

public extension URLQueryItem {
    func toObservable() -> Observable<URLQueryItem> {
        return Observable(self)
    }
}

// MARK: Unique Identifiers

public extension UUID {
    func toObservable() -> Observable<UUID> {
        return Observable(self)
    }
}

// MARK: Geometry

public extension CGFloat {
    func toObservable() -> Observable<CGFloat> {
        return Observable(self)
    }
}

public extension CGAffineTransform {
    func toObservable() -> Observable<CGAffineTransform> {
        return Observable(self)
    }
}

// MARK: Ranges

public extension NSRange {
    func toObservable() -> Observable<NSRange> {
        return Observable(self)
    }
}

// ------------ Dates and Times ------------ //

// MARK: Dates

public extension Date {
    func toObservable() -> Observable<Date> {
        return Observable(self)
    }
}

@available(iOS 10.0, *)
public extension DateInterval {
    func toObservable() -> Observable<DateInterval> {
        return Observable(self)
    }
}

public extension DateComponents {
    func toObservable() -> Observable<DateComponents> {
        return Observable(self)
    }
}

public extension Calendar {
    func toObservable() -> Observable<Calendar> {
        return Observable(self)
    }
}

public extension TimeZone {
    func toObservable() -> Observable<TimeZone> {
        return Observable(self)
    }
}

// MARK: Date Formatting

public extension DateFormatter {
    func toObservable() -> Observable<DateFormatter> {
        return Observable(self)
    }
}

public extension DateComponentsFormatter {
    func toObservable() -> Observable<DateComponentsFormatter> {
        return Observable(self)
    }
}

public extension DateIntervalFormatter {
    func toObservable() -> Observable<DateIntervalFormatter> {
        return Observable(self)
    }
}

@available(iOS 10.0, *)
public extension ISO8601DateFormatter {
    func toObservable() -> Observable<ISO8601DateFormatter> {
        return Observable(self)
    }
}

// MARK: Locale

public extension Locale {
    func toObservable() -> Observable<Locale> {
        return Observable(self)
    }
}

// ------------ Filtering and Sorting ------------ //

// MARK: Filtering

public extension NSPredicate {
    func toObservable() -> Observable<NSPredicate> {
        return Observable(self)
    }
}

// MARK: Sorting

public extension NSSortDescriptor {
    func toObservable() -> Observable<NSSortDescriptor> {
        return Observable(self)
    }
}
