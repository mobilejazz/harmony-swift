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

///
/// Wrapper to allow us to edit a coding key.
///
public struct MutableCodingKey : CodingKey {
    
    public var stringValue: String
    public var intValue: Int?
    
    public init(_ base: CodingKey) {
        self.init(stringValue: base.stringValue, intValue: base.intValue)
    }
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
}
