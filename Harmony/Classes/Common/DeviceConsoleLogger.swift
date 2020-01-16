///
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


/// Prints to the system console
public class DeviceConsoleLogger: Logger {
    
    public init() { }
    
    public func log(level: LogLevel, tag: String?, message: String) {
        if let tag = tag {
            Swift.print("\(levelStringRepresentation(of: level)) - [\(tag)]: \(message)")
        } else {
            Swift.print("\(levelStringRepresentation(of: level)): \(message)")
        }
    }
    
    public func log(key: String, value: Any?) {
        if let value = value {
            log(level: .info, tag: "KEY", message: "\(key): \(value)")
        } else {
            log(level: .info, tag: "KEY", message: "\(key): <nil>")
        }
    }
}

// MARK: - Helpers
private extension DeviceConsoleLogger {
    
    func levelStringRepresentation(of level: LogLevel) -> String {
        switch level {
            case .trace:
                return "TRACE"
            case .debug:
                return "DEBUG"
            case .info:
                return "INFO"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            case .fatal:
                return "FATAL"
        }
    }
}
