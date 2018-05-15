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

public class CoreError : Error, CustomStringConvertible {
    
    public let code : Int
    public let description : String
    
    public init(code: Int = 0, description: String = "") {
        self.code = code
        self.description = description
    }
    
    public var localizedDescription: String {
        return description
    }
    
    public static let domain : String = "com.mobilejazz.core"
    
    public func toNSError() -> NSError {
        return NSError(domain: CoreError.domain, code: code, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
    }
}

extension CoreError {
    
    public class NotFound : CoreError {
        public init(description: String = "Not Found") { super.init(code: 1, description: description) }
    }
    
    public class IllegalArgument : CoreError {
        public init(description: String = "Ilegal Argument") { super.init(code: 2, description: description) }
    }
    
    public class NotValid : CoreError {
        public init(description: String = "Object is not valid") { super.init(code: 3, description: description) }
    }
    
    public class Failed : CoreError {
        public init(description: String = "Action failed") { super.init(code: 4, description: description) }
    }
}

