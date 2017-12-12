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
    
    public override func get(_ query: Query) -> Future<[E]> {
        switch query.self {
        case is QueryById:
            let queryById = query as! QueryById
            return realmHandler.read({ (realm) -> E? in
                let object = realm.object(ofType: O.self, forPrimaryKey: queryById.id)
                if object != nil {
                    return self.toEntityMapper.map(object!)
                } else {
                    return nil
                }
            }).map({ (entity) -> [E] in
                return [entity]
            })
        default:
            if let predicate = query.toRealmQuery().realmPredicate() {
                return realmHandler.read({ (realm) -> [E] in
                    return realm.objects(O.self).filter(predicate).map({ (object) -> E in
                        return self.toEntityMapper.map(object)
                    })
                })
            } else {
                return realmHandler.read({ (realm) -> [E] in
                    return realm.objects(O.self).map({ (object) -> E in
                        return self.toEntityMapper.map(object)
                    })
                })
            }
        }
    }
    
    @discardableResult
    public override func put(_ entities: [E]) -> Future<[E]> {
        return realmHandler.write({ (realm) -> [E] in
            for entity in entities {
                let object = toRealmMapper.map(entity, inRealm:realm)
                realm.add(object, update: true)
            }
            return entities
        })
    }
    
    @discardableResult
    public override func delete(_ query: Query) -> Future<Bool> {
        return realmHandler.write({ (realm) -> Bool in
            if let predicate = query.toRealmQuery().realmPredicate() {
                for object in realm.objects(O.self).filter(predicate) {
                    realm.delete(object)
                }
            } else {
                for object in realm.objects(O.self) {
                    realm.delete(object)
                }
            }
            return true
        })
    }
}
