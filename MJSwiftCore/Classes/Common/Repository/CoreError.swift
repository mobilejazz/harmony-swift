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
/// CoreError is used as a namespace
///
public struct CoreError {
    
    // The domain for all CoreError errors.
    public static let domain = "com.mobilejazz.core.error"
    
    /// Not found error
    public class NotFound : ClassError {
        public init(description: String = "Not Found", userInfo: [String : Any] = [:]) {
            super.init(domain:CoreError.domain, code: 1, description: description, userInfo: userInfo)
        }
    }
    
    /// Illegal argument error
    public class IllegalArgument : ClassError {
        public init(description: String = "Ilegal Argument", userInfo: [String : Any] = [:]) {
            super.init(domain:CoreError.domain, code: 2, description: description, userInfo: userInfo)
        }
    }
    
    /// Not valid error
    public class NotValid : ClassError {
        public init(description: String = "Object is not valid", userInfo: [String : Any] = [:]) {
            super.init(domain:CoreError.domain, code: 3, description: description, userInfo: userInfo)
        }
    }
    
    /// Failed error
    public class Failed : ClassError {
        public init(description: String = "Action failed", userInfo: [String : Any] = [:]) {
            super.init(domain:CoreError.domain, code: 4, description: description, userInfo: userInfo)
        }
    }
}

