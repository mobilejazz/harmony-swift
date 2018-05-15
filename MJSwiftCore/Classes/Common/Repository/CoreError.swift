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
/// CoreError
///
public enum CoreError : Error {
    public typealias RawValue = Int
    
    case notFound
    case illegalArgument(String)
    case notValid
    case failed(String)
    
    public var localizedDescription: String {
        switch self {
        case .notFound:
            return "Object not found"
        case .illegalArgument(let reason):
            return "Illegal argument: \(reason)"
        case .notValid:
            return "Object is not valid"
        case .failed(let reason):
            return "Action failed: \(reason)"
        }
    }
    
    public var code : Int {
        get {
            switch self {
            case .notFound:
                return 1
            case .illegalArgument:
                return 2
            case .notValid:
                return 3
            case .failed:
                return 4
            }
        }
    }
    
    public static let domain : String = "com.mobilejazz.core"
    
    public func toNSError() -> NSError {
        return NSError(domain: CoreError.domain, code: code, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
    }
}
