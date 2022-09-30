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

// MARK: - Constants

struct Constants {
    static let iterationCount = 10000
}

// MARK: - Helpers

func print(average time: UInt64) {
    print(String(format: "Average time: %.10lf", Double(time) / Double(NSEC_PER_SEC)))
}

func print(total time: TimeInterval) {
    print(String(format: "Total time: %.10lf", time))
}

/// Namespace for test helpers.
public enum Test {
    public enum Error: Int, CustomNSError {
        case code13 = 13
        case code42 = 42
        public static var errorDomain: String {
            return "com.mobilejazz.Harmony"
        }

        public var errorCode: Int { return rawValue }
        public var errorUserInfo: [String: Any] { return [:] }
    }
}

// Compare two `Error?`.
public func == (lhs: Error?, rhs: Error?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil):
        return true
    case (nil, _?), (_?, nil):
        return false
    case let (lhs?, rhs?):
        return (lhs as NSError).isEqual(rhs as NSError)
    }
}

public func != (lhs: Error?, rhs: Error?) -> Bool {
    return !(lhs == rhs)
}
