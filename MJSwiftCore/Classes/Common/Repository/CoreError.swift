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

public enum CoreError : Int, Error {
    public typealias RawValue = Int
    
    case unkonwn = 0
    case notFound = 1
    case illegalArgument = 2
    case notValid = 3
    case failed = 4
    
    public var localizedDescription: String {
        switch self {
        case .unkonwn:
            return "Unkonwn error"
        case .notFound:
            return "Object not found"
        case .illegalArgument:
            return "Illegal argument"
        case .notValid:
            return "Object is not valid"
        case .failed:
            return "Action failed"
        }
    }
    
    public var code : Int {
        get { return self.rawValue }
    }
    
    public static let domain : String = "com.mobilejazz.core"
    
    public func toNSError() -> NSError {
        return NSError(domain: CoreError.domain, code: self.code, userInfo: [NSLocalizedDescriptionKey : self.localizedDescription])
    }
}
