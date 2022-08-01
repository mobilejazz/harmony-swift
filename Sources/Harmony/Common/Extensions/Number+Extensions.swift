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

public extension Int {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> Int {
        return Int.random(in: Int.min...Int.max)
    }
}

public extension Int8 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> Int8 {
        return Int8.random(in: Int8.min...Int8.max)
    }
}

public extension Int16 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> Int16 {
        return Int16.random(in: Int16.min...Int16.max)
    }
}

public extension Int32 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> Int32 {
        return Int32.random(in: Int32.min...Int32.max)
    }
}

public extension Int64 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> Int64 {
        return Int64.random(in: Int64.min...Int64.max)
    }
}

public extension UInt {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> UInt {
        return UInt.random(in: UInt.min...UInt.max)
    }
}

public extension UInt8 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> UInt8 {
        return UInt8.random(in: UInt8.min...UInt8.max)
    }
}

public extension UInt16 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> UInt16 {
        return UInt16.random(in: UInt16.min...UInt16.max)
    }
}

public extension UInt32 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> UInt32 {
        return UInt32.random(in: UInt32.min...UInt32.max)
    }
}

public extension UInt64 {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> UInt64 {
        return UInt64.random(in: UInt64.min...UInt64.max)
    }
}

public extension Float {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> Float {
        return Float.random(in: Float.leastNormalMagnitude...Float.greatestFiniteMagnitude)
    }
}

public extension Double {
    /// Returns a random value.
    /// - Returns: A random value.
    static func random() -> Double {
        return Double.random(in: Double.leastNormalMagnitude...Double.greatestFiniteMagnitude)
    }
}
