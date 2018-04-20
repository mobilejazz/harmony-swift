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
public class ExecutorFactory {
    
    public enum Scope {
        case none
        case string(String)
        case integer(Int)
        case type(String)
    }
    
    private let builder : (String) -> Executor
    private var stringScope : [String : Executor] = [:]
    private var integerScope : [Int : Executor] = [:]
    private var typeScope : [String : Executor] = [:]
    
    public init(_ builder: @escaping (String) -> Executor) {
        self.builder = builder
    }
    
    private func get(_ scope: Scope, named name: String) -> Executor {
        switch scope {
        case .none:
            return builder(name)
        case .string(let value):
            if let executor = stringScope[value] {
                return executor
            } else {
                let executor = builder(name)
                stringScope[value] = executor
                return executor
            }
        case .type(let value):
            if let executor = typeScope[value] {
                return executor
            } else {
                let executor = builder(name)
                typeScope[value] = executor
                return executor
            }
        case .integer(let value):
            if let executor = integerScope[value] {
                return executor
            } else {
                let executor = builder(name)
                integerScope[value] = executor
                return executor
            }
        }
    }
    
    public func get(named name: String = "com.mobilejazz.executor.default") -> Executor {
        return get(.none, named: name)
    }
    
    public func get(_ string: String) -> Executor {
        return get(.string(string), named: "executor." + string)
    }
    
    public func get(_ value: Int) -> Executor {
        return get(.integer(value), named: "executor.\(value)")
    }
    
    public func get<T>(_ type: T.Type) -> Executor {
        let string = String(describing: type)
        return get(.type(string), named: string)
    }
}
