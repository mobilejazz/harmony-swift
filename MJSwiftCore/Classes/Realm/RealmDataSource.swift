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

extension QueryById : RealmQuery where T==String {
    public func realmPredicate() -> NSPredicate? {
        return NSPredicate(format: "id == %@", id)
    }
}

extension AllObjectsQuery : RealmQuery { }

fileprivate extension Query {
    fileprivate func toRealmQuery() -> RealmQuery {
        if case let query as RealmQuery = self {
            return query
        }
        fatalError("Query class \(String(describing: type(of:self))) cannot be used in realm. Fix by conforming to protocol RealmQuery.")
    }
}

public class RealmDataSource<E: Entity, O: Object> : DataSource<E> {
    
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
    
    private func idFromQuery(_ query: Query) -> String? {
        if case let query as QueryById<String> = query.self {
            return query.id
        }
        return nil
    }
    
    public override func get(_ query: Query) -> Future<E?> {
        if let id = idFromQuery(query) {
            return realmHandler.read { realm in
                let primaryKey : String = id
                return realm.object(ofType: O.self, forPrimaryKey: primaryKey)
                }.unwrappedMap { o in self.toEntityMapper.map(o) }
        } else {
            // Otherwise, the get method can't resolve the query.
            // It needs to be done via a getAll call, as the return is an array of objects.
            return super.get(query)
        }
    }
    
    public override func getAll(_ query: Query = AllObjectsQuery()) -> Future<[E]> {
        if let _ = idFromQuery(query) {
            return self.get(query).unwrappedMap{ [$0] }.unwrap()
        } else {
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
    
    @discardableResult
    public override func put(_ value: E?, in query: Query = BlankQuery()) -> Future<E> {
        return realmHandler.write { realm -> E in
            let object = toRealmMapper.map(value!, inRealm: realm)
            realm.add(object)
            return value!
        }.unwrap()
    }
    
    @discardableResult
    public override func putAll(_ array: [E], in query: Query = BlankQuery()) -> Future<[E]> {
        return realmHandler.write { realm -> [E] in
            array
                .map { toRealmMapper.map($0, inRealm:realm) }
                .forEach { realm.add($0, update: true) }
            return array
            }.unwrap()
    }
    
    
    @discardableResult
    public override func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as ObjectQuery<E>:
            return realmHandler.write { realm in
                let object = toRealmMapper.map(query.object, inRealm: realm)
                realm.delete(object)
                return Void()
            }.unwrap()
        default:
            return super.delete(query)
        }
    }
    
    @discardableResult
    public override func deleteAll(_ query: Query = BlankQuery()) -> Future<Void> {
        switch query {
        case let query as ObjectsQuery<E>:
            return realmHandler.write { realm in
                query.objects
                    .map { toRealmMapper.map($0, inRealm: realm) }
                    .forEach { realm.delete($0) }
                return Void()
                }.unwrap()
        case is AllObjectsQuery:
            return realmHandler.write { realm in
                realm.objects(O.self).forEach { realm.delete($0) }
                return Void()
                }.unwrap()
        default:
            if let predicate = query.toRealmQuery().realmPredicate() {
                return realmHandler.write { realm in
                    realm.objects(O.self).filter(predicate).forEach { realm.delete($0) }
                    return Void()
                    }.unwrap()
            } else {
                return super.deleteAll(query)
            }
        }
    }
}
