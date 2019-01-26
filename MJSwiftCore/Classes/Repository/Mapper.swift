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

///
/// Abstract class to map an object type to another object type
///
open class Mapper <From,To> {
    
    /// Default initializer
    public init() { }
    
    /// Mapping method
    ///
    /// - Parameter from: The original object
    /// - Returns: The new mapped object
    /// - Throws: Mapping error. Typically of type CoreError.Failed
    open func map(_ from: From) throws -> To {
        fatalError("Undefined mapper. Class Mapper must be subclassed.")
    }
}

extension Mapper {
    /// Mapping method for arrays
    ///
    /// - Parameter array: An array of objects
    /// - Returns: An array of mapped objects
    /// - Throws: Mapping error. Typically of type CoreError.Failed
    public func map(_ array: [From]) throws -> [To] {
        return try array.map { try map($0) }
    }
    
    // Mapping method for dictionaries
    ///
    /// - Parameter dictionary: A dictionary of key-value, where value is typed as "From"
    /// - Returns: A dictionary of mapped values
    /// - Throws: Mapping error. Typically of type CoreError.Failed
    public func map<K>(_ dictionary: [K:From]) throws -> [K:To] {
        return try dictionary.mapValues { try map($0) }
    }
}

extension Mapper where From: Hashable, To : Hashable {
    /// Mapping method for sets
    ///
    /// - Parameter set: A set to be mapped
    /// - Returns: A mapped set
    /// - Throws: Mapping error. Typically of type CoreError.Failed
    public func map(_ set: Set<From>) throws -> Set<To> {
        return Set(try set.map { try map($0) })
    }
}

///
/// VoidMapper throws a CoreError.NotImplemented
///
public class VoidMapper <From,To> : Mapper <From,To> {
    public override func map(_ from: From) throws -> To {
        throw CoreError.NotImplemented()
    }
}

///
/// A mock mapper returns the mock object when mapping any object.
///
public class MockMapper <From,To> : Mapper <From,To> {
    private let mock : To
    
    /// Default initializer
    ///
    /// - Parameter mock: The mock object to return when mapping.
    public init(_ mock: To) {
        self.mock = mock
    }
    
    public override func map(_ from: From) throws -> To {
        return mock
    }
}

///
/// IdentityMapper returns the same value
///
public class IdentityMapper <T> : Mapper <T,T> {
    public override func map(_ from: T) throws -> T {
        return from
    }
}

///
/// CastMapper tries to casts the input value to the mapped type. Otherwise, throws an CoreError.Failed error.
///
public class CastMapper <From,To> : Mapper <From,To> {
    public override func map(_ from: From) throws -> To {
        guard let to = from as? To else {
            throw CoreError.Failed("CastMapper failed to map an object of type \(type(of: from)) to \(String(describing: To.self))")
        }
        return to
    }
}

///
/// Mapper defined by a closure
///
public class ClosureMapper <From,To> : Mapper <From,To> {
    
    private let closure : (From) throws -> To
    
    /// Default initializer
    ///
    /// - Parameter closure: The map closure
    public init (_ closure : @escaping (From) throws -> To) {
        self.closure = closure
        super.init()
    }
    
    public override func map(_ from: From) throws -> To {
        return try closure(from)
    }
}

///
/// Composes a two mappers A->B & B->C to create a mapper A->C.
///
public class ComposedMapper <A,B,C> : Mapper <A,C> {
    
    private let mapperAB : Mapper <A,B>
    private let mapperBC : Mapper <B,C>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - mapperAB: Mapper A->B
    ///   - mapperBC: Mapper B->C
    public init(_ mapperAB: Mapper <A,B>, _ mapperBC: Mapper<B,C>) {
        self.mapperAB = mapperAB
        self.mapperBC = mapperBC
    }
    
    public override func map(_ from: A) throws -> C {
        return try mapperBC.map(try mapperAB.map(from))
    }
}

// MARK: Data - String

///
/// Converts Data into a base64 encoded string
///
public class DataToBase64StringMapper : Mapper <Data,String> {
    public override func map(_ from: Data) throws -> String {
        return from.base64EncodedString()
    }
}

///
/// Converts base64 encoded string to data.
/// Throws CoreError.Failed if string is invalid.
///
public class Base64StringToDataMapper : Mapper <String,Data> {
    public override func map(_ from: String) throws -> Data {
        guard let data = Data(base64Encoded: from) else {
            throw CoreError.Failed("Failed to map String into Data.")
        }
        return data
    }
}

///
/// Converts Data into a hexadecimal encoded string
///
public class DataToHexStringMapper : Mapper <Data,String> {
    public override func map(_ from: Data) throws -> String {
        return from.hexEncodedString()
    }
}

///
/// Converts hexadecimal encoded string to data.
/// Throws CoreError.Failed if string is invalid.
///
public class HexStringToDataMapper : Mapper <String,Data> {
    public override func map(_ from: String) throws -> Data {
        guard let data = Data(hexEncoded: from) else {
            throw CoreError.Failed("Failed to map String into Data.")
        }
        return data
    }
}
