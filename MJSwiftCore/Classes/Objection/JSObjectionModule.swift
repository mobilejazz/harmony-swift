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

public enum ObjectionScope {
    case normal
    case singleton
}

internal extension ObjectionScope {
    internal func scope() -> JSObjectionScope {
        switch self {
        case .normal:
            return JSObjectionScopeNormal
        case .singleton:
            return JSObjectionScopeSingleton
        }
    }
}

public extension JSObjectionModule {
    // Swift binding method
    public func bind<T>(_ type: T.Type, to provider: JSObjectionProvider) where T:AnyObject {
        bindProvider(provider, to: type as AnyClass)
    }
    /// Swift binding method
    public func bind(_ type: Protocol, to provider: JSObjectionProvider) {
        bindProvider(provider, to: type)
    }
    /// Swift binding method
    public func bind<T>(_ type: T.Type, scope: ObjectionScope = .normal, _ closure: @escaping (JSObjectionInjector) -> T) where T:AnyObject {
        bindBlock({ closure($0!) }, to: type as AnyClass, in: scope.scope())
    }
    /// Swift binding method
    public func bind(_ type: Protocol, scope: ObjectionScope = .normal, _ closure: @escaping (JSObjectionInjector) -> AnyObject) {
        bindBlock({ closure($0!) }, to: type, in: scope.scope())
    }
    /// Swift binding method
    public func bind<T>(_ type: T.Type, scope: ObjectionScope = .normal, named name: String, _ closure: @escaping (JSObjectionInjector) -> T) where T:AnyObject {
        bindBlock({ closure($0!) }, to: type as AnyClass, in: scope.scope(), named: name)
    }
    /// Swift binding method
    public func bind(_ type: Protocol, named name: String, scope: ObjectionScope = .normal, _ closure: @escaping (JSObjectionInjector) -> AnyObject) {
        bindBlock({ closure($0!) }, to: type, in: scope.scope(), named: name)
    }
    /// Swift eager singletons
    public func registerEagerSingleton<T>(_ type: T.Type) where T:AnyObject {
        registerEagerSingleton(type as AnyClass)
    }
}
