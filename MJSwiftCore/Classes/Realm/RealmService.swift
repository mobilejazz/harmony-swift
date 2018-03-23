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

public protocol RealmQuery : Query {
    func realmPredicate() -> NSPredicate?
}

public extension RealmQuery {
    public func realmPredicate() -> NSPredicate? {
        return nil
    }
}

extension NSPredicate : RealmQuery {
    public func realmPredicate() -> NSPredicate? {
        return self
    }
}

extension QueryById : RealmQuery {
    public func realmPredicate() -> NSPredicate? {
        return NSPredicate(format: "id == %@", id)
    }
}
extension AllObjectsQuery : RealmQuery { }

fileprivate extension Query {
    fileprivate func toRealmQuery() -> RealmQuery {
        switch self {
        case is RealmQuery:
            return self as! RealmQuery
        default:
            fatalError("Query class \(String(describing: type(of:self))) cannot be used in realm. Fix by conforming to protocol RealmQuery.")
        }
    }
}

public class RealmService<E: Entity, O: Object> : Repository<E> {
    
    let realmHandler: RealmHandler
    let toEntityMapper: Mapper<O,E>
    let toRealmMapper: RealmMapper<E,O>
    
    public init(realmHandler: RealmHandler,
                toEntityMapper: Mapper<O,E>,
                toRealmMapper: RealmMapper<E,O>) {
        self.realmHandler = realmHandler
        self.toEntityMapper = toEntityMapper
        self.toRealmMapper = toRealmMapper
    }
    
    public override func get(_ query: Query, operation: Operation) -> Future<E?> {
        // TODO
        return Future()
    }
    
    public override func getAll(_ query: Query, operation: Operation) -> Future<[E]> {
        switch query.self {
        case is QueryById:
            let queryById = query as! QueryById
            return realmHandler.read { realm -> E? in
                if let object = realm.object(ofType: O.self, forPrimaryKey: queryById.id) {
                    return toEntityMapper.map(object)
                } else {
                    return nil
                }
            }.map { entity -> [E] in
                guard let entity = entity else {
                    return []
                }
                return [entity]
            }
        default:
            if let predicate = query.toRealmQuery().realmPredicate() {
                return realmHandler.read { realm -> [E] in
                    return Array(realm.objects(O.self).filter(predicate)).map { toEntityMapper.map($0) }
                }.unwrap()
            } else {
                return realmHandler.read { realm -> [E] in
                    return Array(realm.objects(O.self)).map { toEntityMapper.map($0) }
                }.unwrap()
            }
        }
    }
    
    public override func put(_ value: E, in query: Query, operation: Operation) -> Future<E> {
        // TODO
        return Future()
    }
    
    public override func putAll(_ array: [E], in query: Query, operation: Operation) -> Future<[E]> {
        return realmHandler.write { realm -> [E] in
            array
                .map { toRealmMapper.map($0, inRealm:realm) }
                .forEach { realm.add($0, update: true) }
            return array
            }.unwrap()
    }
    
    @discardableResult
    public override func deleteAll(_ array: [E], in query: Query, operation: Operation) -> Future<Bool> {
        switch query {
        case is BlankQuery:
            return realmHandler.write { realm -> Bool in
                array
                    .map { toRealmMapper.map($0, inRealm: realm) }
                    .forEach { realm.delete($0) }
                return true
                }.unwrap()
        default:
            return realmHandler.write { realm -> Bool in
                if let predicate = query.toRealmQuery().realmPredicate() {
                    realm.objects(O.self).filter(predicate).forEach { realm.delete($0) }
                } else {
                    realm.objects(O.self).forEach { realm.delete($0) }
                }
                return true
                }.unwrap()
        }
    }
}
