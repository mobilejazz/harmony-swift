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

/// Information that gets logged can be labeled as one of the following informative labels.
@objc(MJLogLevel) public enum LogLevel: Int {
    case trace
    case debug
    case info
    case warning
    case error
    case fatal
}

/// Abstracts concrete implementations of a logger system.
@objc(MJLogger) public protocol Logger {
    
    /// Logs a String object using a given level
    ///
    /// - Parameters:
    ///   - level: Type of log.
    ///   - tag: An additional label to help categorise logs.
    ///   - message: The message to be logged.
    func log(level: LogLevel, tag: String?, message: String)
    
    /// Logs a key-value pair
    ///
    /// - Parameters:
    ///   - key: They key
    ///   - value: The value
    func log(key: String, value: Any?)
}

// MARK: - Default implementations
public extension Logger {
    
    /// Logs a String message using an trace level.
    ///
    /// - Parameters:
    ///   - tag: An additional label to help categorise logs.
    ///   - message: String to be logged
    func trace(tag: String? = nil, _ message: String) {
        self.log(level: .trace, tag: tag, message: message)
    }
    
    /// Logs a String message using an debug level.
    ///
    /// - Parameters:
    ///   - tag: An additional label to help categorise logs.
    ///   - message: String to be logged
    func debug(tag: String? = nil, _ message: String) {
        self.log(level: .debug, tag: tag, message: message)
    }
    
    /// Logs a String message using an info level.
    ///
    /// - Parameters:
    ///   - tag: An additional label to help categorise logs.
    ///   - message: String to be logged
    func info(tag: String? = nil, _ message: String) {
        self.log(level: .info, tag: tag, message: message)
    }
    
    /// Logs a String message using a warning level.
    ///
    /// - Parameters:
    ///   - tag: An additional label to help categorise logs.
    ///   - message: String to be logged
    func warning(tag: String? = nil, _ message: String) {
        self.log(level: .warning, tag: tag, message: message)
    }
    
    /// Logs a String message using an error level.
    ///
    /// - Parameters:
    ///   - tag: An additional label to help categorise logs.
    ///   - message: String to be logged
    func error(tag: String? = nil, _ message: String) {
        self.log(level: .error, tag: tag, message: message)
    }
    
    /// Logs a String message using a fatal level.
    ///
    /// - Parameters:
    ///   - tag: An additional label to help categorise logs.
    ///   - message: String to be logged
    func fatal(tag: String? = nil, _ message: String) {
        self.log(level: .fatal, tag: tag, message: message)
    }
    
    /// Logs a key-value pair
    ///
    /// - Parameters:
    ///   - key: They key
    ///   - value: The value
    func log(key: String, value: Any?) {
        self.info("\(key)=\(value ?? "-")")        
    }
}

/// Logger that does nothing.
public class VoidLogger : Logger {
    public init() {}
    public func log(level: LogLevel, tag: String?, message: String) {}
    public func log(key: String, value: Any?) {}
}
