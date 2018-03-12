//
// Copyright 2018 Mobile Jazz SL
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

extension URL : DataConvertible {
    public init?(data: Data) {
        self.init(dataRepresentation: data, relativeTo: nil)
    }
    public var data: Data {
        return self.dataRepresentation
    }
}

extension Date : DataConvertible {
    public init?(data: Data) {
        var components = DateComponents()
        
        let year : Data = data.subdata(in: Range(NSMakeRange(0, 2))!)
        var yearVal: UInt32 = 0
        (year as NSData).getBytes(&yearVal, length: MemoryLayout.size(ofValue: year))
        
        components.year = Int(yearVal)
        components.month = Int(data[2])
        components.day = Int(data[3])
        components.hour = Int(data[4])
        components.minute = Int(data[5])
        components.second = Int(data[6])
        
        self = Calendar(identifier: .gregorian).date(from: components)!
    }
    public var data: Data {
        let cal = Calendar(identifier: .gregorian)
        let comp = cal.dateComponents([.day,.month,.year,.hour,.minute,.second], from: self)
        let year = comp.year!
        let yearLo = UInt8(year & 0xFF) // mask to avoid overflow error on conversion to UInt8
        let yearHi = UInt8(year >> 8)
        let settingArray = [UInt8]([yearLo,
                                    yearHi,
                                    UInt8(comp.month!),
                                    UInt8(comp.day!),
                                    UInt8(comp.hour!),
                                    UInt8(comp.minute!),
                                    UInt8(comp.second!),
                                    ])
        return Data(bytes: settingArray)
    }
}
