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

public protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible {
    public init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else {
            return nil
        }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    public var data: Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension Int : DataConvertible { }

extension Float : DataConvertible { }

extension Double : DataConvertible { }

extension UInt : DataConvertible { }

extension String : DataConvertible {
    public init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }
    public var data: Data {
        return self.data(using: .utf8)!
    }
}

extension Data : DataConvertible {
    public init?(data: Data) {
        self = data
    }
    public var data: Data {
        return self
    }
}

/// Custom mapper to convert to data from data convertible
public class toDataMapper <T:DataConvertible> : Mapper<T,Data> {
    public override func map(_ from: T) -> Data {
        return from.data
    }
}

/// Custom mapper to convert to data converitble from mapa
public class toDataConvertibleMapper <T:DataConvertible> : Mapper<Data,T> {
    public override func map(_ from: Data) -> T {
        return T(data:from)!
    }
}

/// Custom mapper to convert queries to data
public class DataConvertibleQueryMapper <T:DataConvertible> : Mapper<Query,Query> {
    public override func map(_ from: Query) -> Query {
        switch from.self {
        case is KeyValueQuery<T>:
            let query = from as! KeyValueQuery<T>
            return KeyValueQuery<Data>(query.key, query.value.data)
        default:
            return from
        }
    }
}