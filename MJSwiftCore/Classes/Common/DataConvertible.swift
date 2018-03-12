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

/// DataCodable defines a method to convert the object to Data
public protocol DataCodable {
    func toData() -> Data
}

/// DataDecodable defines a method to instantiate an object from Data
public protocol DataDecodable {
    init?(data: Data)
}

/// DataConvertible conforms to both protocols DataCodable and DataDecodable
public protocol DataConvertible : DataCodable, DataDecodable { }

extension DataDecodable {
    /// Default implementation where the object is created directly from its bytes
    public init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else {
            return nil
        }
        self = data.withUnsafeBytes { $0.pointee }
    }
}

extension DataCodable {
    /// Default implementation where data is extracted from the object by accessing its memory buffer
    public func toData() -> Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}
