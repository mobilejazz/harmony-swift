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
    
    private init() { }
    
    // The domain for all CoreError errors.
    public static let domain = "com.mobilejazz.core.error"
    
    /// Unknown error
    public class Unknown : ClassError {
        public init(_ description: String = "Unknown Error") {
            super.init(domain: CoreError.domain, code: 0, description: description)
        }
        
        public override init(domain: String , code: Int, description: String) {
            super.init(domain: domain, code: code, description: description)
        }
    }
    
    /// Not found error
    public class NotFound : ClassError {
        public init(_ description: String = "Not Found") {
            super.init(domain:CoreError.domain, code: 1, description: description)
        }
    }
    
    /// Illegal argument error
    public class IllegalArgument : ClassError {
        public init(_ description: String = "Illegal Argument") {
            super.init(domain:CoreError.domain, code: 2, description: description)
        }
    }
    
    /// Illegal argument error
    public class NotImplemented : ClassError {
        public init(_ description: String = "Not Implemented") {
            super.init(domain:CoreError.domain, code: 3, description: description)
        }
    }
    
    /// Not valid error
    public class NotValid : ClassError {
        public init(_ description: String = "Object or action not valid") {
            super.init(domain:CoreError.domain, code: 4, description: description)
        }
    }
    
    /// Failed error
    public class Failed : ClassError {
        public init(_ description: String = "Action failed") {
            super.init(domain:CoreError.domain, code: 5, description: description)
        }
    }
}

extension CoreError {

    /// A base implementation for NSError to ClassError conversion
    public class NSError : Unknown {
        /// The NSError
        public let error : Foundation.NSError
        
        /// Default initializer
        ///
        /// - Parameter error: The incoming NSError
        public init(_ error : Foundation.NSError) {
            self.error = error
            super.init(domain: error.domain, code: error.code, description: error.localizedDescription)
        }
        
        public override func userInfo() -> [String : Any] {
            return error.userInfo
        }
    }
    
    /// OSStatus fail error. Subtype of Failed error.
    public class OSStatusFailure : Failed {
        /// The OSStatus
        public let status : OSStatus
        
        /// Default initializer
        ///
        /// - Parameters:
        ///   - status: The incoming OSStatus
        ///   - description: The optional description
        public init(_ status: OSStatus, _ description: String? = nil) {
            self.status = status
            super.init(description ?? "OSStatus failure with code \(status)")
        }
        
        public override func userInfo() -> [String : Any] {
            var userInfo = super.userInfo()
            userInfo["OSStatus"] = status
            return userInfo
        }
    }
}

