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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implOied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// Operator + overriding
public func +<T,K>(left: Future<T>, right: Future<K>) -> Future<(T,K)> {
    return left.zip(right)
}

precedencegroup MapPrecedance {
    associativity: left
}
infix operator <^> : MapPrecedance

/// Map operator
public func <^><T,K>(future: Future<T>, map: @escaping (T) -> K) -> Future<K> {
    return future.map { value in map(value) }
}
