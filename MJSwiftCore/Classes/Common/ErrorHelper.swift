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

public enum GenericError : Error {
    case unknown
    case string(String)
    case int(Int)
    case object(AnyObject)
    
    public var localizedDescription: String {
        switch self {
        case .unknown:
            return "Error : Unknown"
        case .string(let string):
            return "Error : \(string)"
        case .int(let value):
            return "Error : \(value)"
        case .object(let object):
            return "Error: \(object)"
        }
    }
}

public func NSErrorDomain(_ string: String = "", domain: String = "\(Bundle.main.bundleIdentifier!)") -> String {
    return domain + "." + string
}

public extension NSError {
    public convenience init(_ message: String, reason: String? = nil, domain: String = NSErrorDomain(), code: Int = 0, userInfo: (inout [String : Any]) -> Void = { _ in }) {
        var userInfoDict: [String : Any] = [NSLocalizedDescriptionKey : message]
        if let reason = reason {
            userInfoDict[NSLocalizedFailureReasonErrorKey] = reason
        }
        
        userInfo(&userInfoDict)
        
        self.init(domain: domain, code: code, userInfo: userInfoDict)
    }
    
    public convenience init(_ message: String, reason: String? = nil, subdomain: String, code: Int = 0, userInfo: (inout [String : Any]) -> Void = { _ in }) {
        self.init(message, reason: reason, domain: NSErrorDomain(subdomain), code: code, userInfo: userInfo)
    }
}
