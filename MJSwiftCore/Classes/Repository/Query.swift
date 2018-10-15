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
/// Default query interface
///
public protocol Query { }

/// Void query
public class VoidQuery : Query {
    public init() { }
}

/// A query by an id
public class IdQuery<T> where T:Hashable {
    public let id : T
    public init(_ id: T) {
        self.id = id
    }
}

/// A query by an array of Ids
public class IdsQuery<T> where T:Hashable {
    public let ids : [T]
    public init(_ ids: [T]) {
        self.ids = ids
    }
}

/// All objects query
public class AllObjectsQuery : Query {
    public init() { }
}

/// Single object query
public class ObjectQuery<T> : Query {
    public let value : T
    public init(_ value : T) {
        self.value = value
    }
}

/// Array based query
public class ObjectsQuery<T> : Query {
    public let values : [T]
    public init(_ values : [T]) {
        self.values = values
    }
}

/// Abstract pagination query
public class PaginationQuery : Query { }

/// Pagination by offset and limit
public class PaginationOffsetLimitQuery : PaginationQuery {
    public let offset : Int
    public let limit : Int
    public init(_ offset : Int, _ limit : Int) {
        self.offset = offset
        self.limit = limit
    }
}

/// Generic query representing insertion of objects. Typically used in PUT functions.
public class InsertObjectQuery : Query {
    public init() { }
}

/// Generic query representing update of objects. Typically used in PUT functions.
public class UpdateObjectQuery : Query {
    public init() { }
}
