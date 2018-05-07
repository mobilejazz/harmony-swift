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

/// Default query interface
public protocol Query { }

/// Blank query
public class BlankQuery : Query {
    public init() {}
}

/// A query by an id
public class QueryById <T> where T:Hashable {
    public let id : T
    public init(_ id: T) {
        self.id = id
    }
}

/// All objects query
public class AllObjectsQuery : Query {
    public init() { }
}
