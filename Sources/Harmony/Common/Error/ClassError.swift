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
/// Convenience superclass for error classes.
/// By defining errors as a class, generic errors listed as "Error" can be easily casted and compared.
///
/// Example of custom error:
///
///     public class NotFoundError : ClassError {
///         public init(description: String = "Not Found", userInfo: [String : Any] = [:]) {
///             super.init(code: 1, description: description, userInfo: userInfo)
///         }
///     }
///
/// Example of error usage:
///
///     func handle(error: Error) {
///         switch error {
///         case is NotFoundError:
///             // Handle not found case
///         default:
///             // Other error
///             break
///         }
///     }
///
open class ClassError : Error, CustomStringConvertible {
    
    /// The error's domain
    public let domain : String
    
    /// The error's code
    public let code : Int
    
    /// The error's description
    public let description : String
    
    /// Main initializer
    ///
    /// - Parameters:
    ///   - domain:  The error's context. Default value is "default".
    ///   - code: The error's code
    ///   - description: The error's description
    ///   - userInfo: The error's user info (default is empty dictionary)
    public init(domain: String = "default" , code: Int, description: String) {
        self.domain = domain
        self.code = code
        self.description = description
    }
    
    /// Localized error description
    public var localizedDescription: String {
        return description
    }
   
    /// Subclasses can override this method to return a custom user info for NSError transformation
    open func userInfo() -> [String:Any] {
        return [NSLocalizedDescriptionKey : description]
    }
    
    /// Converts the CoreError into a NSError format
    /// - Parameter domain: The domain for the NSError. If nil (default), the domain used is self.domain
    /// - Returns: An NSError instnace
    public func toNSError(domain: String? = nil) -> NSError {
        return NSError(domain: domain ?? self.domain, code: code, userInfo: userInfo())
    }
}

extension ClassError : LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        return description
    }
}


extension ClassError : Hashable {
    /// Hash method
    public func hash(into hasher: inout Hasher) {
        hasher.combine(domain)
        hasher.combine(code)
    }
}

extension ClassError : Equatable {
    /// Two ClassError are the same if code and domain are the same.
    public static func ==(lhs: ClassError, rhs: ClassError) -> Bool {
        return lhs.code == rhs.code && lhs.domain == rhs.domain
    }
}

extension ClassError : CustomDebugStringConvertible {
    /// Debug description
    public var debugDescription: String {
        return "Error Code <\(code)>: \(description)"
    }
}
