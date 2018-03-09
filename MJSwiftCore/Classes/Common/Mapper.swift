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

open class Mapper<From, To> {
    public init() { }
    open func map(_ from: From) -> To {
        fatalError("Undefined mapper. Class Mapper must be subclassed.")
    }
}

extension Mapper {
    public func map( _ array: Array<From>) -> Array<To> {
        return array.map { value -> To in
            return map(value)
        }
    }
}

///
/// BlankMapper returns the same value as map
///
public class BlankMapper<T> : Mapper<T,T> {
    public override func map(_ from: T) -> T {
        return from
    }
}

///
/// CastMapper returns the same value but casted
///
public class CastMapper<T,Q> : Mapper<T,Q> {
    public override func map(_ from: T) -> Q {
        return from as! Q
    }
}
