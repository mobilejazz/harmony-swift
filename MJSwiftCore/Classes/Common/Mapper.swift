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
    open func map(_ from: From) -> To {
        fatalError("Undefined mapper. Class Mapper must be subclassed.")
    }
}

extension Mapper {
    /// Mapping method for arrays
    ///
    /// - Parameter array: An array of objects
    /// - Returns: An array of mapped objects
    public func map( _ array: [From]) -> [To] {
        return array.map { value -> To in
            return map(value)
        }
    }
    
    // Mapping method for dictionaries
    ///
    /// - Parameter dictionary: A dictionary of key-value, where value is typed as "From"
    /// - Returns: A dictionary of mapped values
    public func map<K>(_ dictionary: [K:From]) -> [K:To] where K:Hashable {
        return dictionary.mapValues { value in
            return map(value)
        }
    }
}

///
/// BlankMapper returns the same value
///
public class BlankMapper <T> : Mapper <T,T> {
    public override func map(_ from: T) -> T {
        return from
    }
}

///
/// CastMapper casts the input value to the mapped type
///
public class CastMapper <From,To> : Mapper <From,To> {
    public override func map(_ from: From) -> To {
        return from as! To
    }
}

///
/// Mapper defined by a closure
///
public class ClosureMapper <From,To> : Mapper <From,To> {
    
    private let closure : (From) -> To
    
    /// Default initializer
    ///
    /// - Parameter closure: The map closure
    public init (_ closure : @escaping (From) -> To) {
        self.closure = closure
        super.init()
    }
    
    public override func map(_ from: From) -> To {
        return closure(from)
    }
}
