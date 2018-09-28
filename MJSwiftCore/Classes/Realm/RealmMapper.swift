//
// Copyright 2017 Mobile Jazz SL
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
import RealmSwift

open class RealmMapper <From:RealmEntity, To:Object> {
    public init() { }
    open func map(_ from: From, inRealm realm: Realm) throws -> To {
        fatalError()
    }
}

extension RealmMapper {
    public func map( _ array: [From], inRealm realm: Realm) throws -> List<To> {
        let list = List<To>()
        for value in array {
            let object = try map(value, inRealm: realm)
            list.append(object)
        }
        return list
    }
}

extension Mapper where From : Object, To: RealmEntity {
    public func map(_ results: Results<From>) throws -> [To] {
        return try results.map { object -> To in
            return try self.map(object)
        }
    }
    
    public func map(_ list: List<From>) throws -> [To] {
        return try list.map { object -> To in
            return try self.map(object)
        }
    }
}
