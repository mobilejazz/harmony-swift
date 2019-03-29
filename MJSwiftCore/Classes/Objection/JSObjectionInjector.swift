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
import MJObjection

public extension JSObjectionInjector {
    /// Swift injection method
    func get<T>(_ type: T.Type) -> T {
        return getObject(type) as! T
    }
    /// Swift injection method
    func get<T>(_ type: T.Type, named name: String) -> T {
        return getObject(type, named: name) as! T
    }
    /// Swift injection method
    func get<T>(_ type: T.Type, argumentList: [Any]) -> T {
        return getObject(type, argumentList: argumentList) as! T
    }
    /// Swift injection method
    func get<T>(_ type: T.Type, named name: String, argumentList: [Any]) -> T {
        return getObject(type, named: name, argumentList: argumentList) as! T
    }
    /// Swift injection method
    func get<T>(_ type: T.Type, arguments: CVaListPointer) -> T {
        return getObject(type, arguments: arguments) as! T
    }
    /// Swift injection method
    func get<T>(_ type: T.Type, named name: String, arguments: CVaListPointer) -> T {
        return getObject(type, named: name, arguments: arguments) as! T
    }
}
