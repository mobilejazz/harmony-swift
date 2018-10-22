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

///
/// Note that id can only be either String or Int.
///
public protocol RealmEntity {
    associatedtype T : Hashable
    var id : T? { get }
}

public protocol RealmQuery : Query {
    var realmPredicate : NSPredicate { get }
}

extension NSPredicate : RealmQuery {
    public var realmPredicate : NSPredicate {
        get { return self }
    }
}

public class RealmDataSource <E: RealmEntity, O: Object> : GetDataSource, PutDataSource, DeleteDataSource {
    
    public typealias T = E
    
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
    
    public func get(_ query: Query) -> Future<E> {
        switch query {
        case let query as IdQuery<String>:
            return realmHandler.read { realm in
                return realm.object(ofType: O.self, forPrimaryKey: query.id)
                }.map { try self.toEntityMapper.map($0) }
        case let query as IdQuery<Int>:
            return realmHandler.read { realm in
                return realm.object(ofType: O.self, forPrimaryKey: query.id)
                }.map { try self.toEntityMapper.map($0) }
        default:
            query.fatalError(.get, self)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[E]> {
        switch query {
        case is AllObjectsQuery:
            return realmHandler.read { realm in
                return Array(realm.objects(O.self))
                }.map { try self.toEntityMapper.map($0) }
        case let query as RealmQuery:
            return realmHandler.read { realm in
                return Array(realm.objects(O.self).filter(query.realmPredicate))
                }.map { try self.toEntityMapper.map($0) }
        default:
            query.fatalError(.getAll, self)
        }
    }
    
    @discardableResult
    public func put(_ value: E?, in query: Query) -> Future<E> {
        switch query {
        case is PutQuery:
            guard let value = value else {
                return Future(CoreError.IllegalArgument("Value cannot be nil"))
            }
            return realmHandler.write { realm in
                let object = try toRealmMapper.map(value, inRealm: realm)
                realm.add(object)
                return object
                }.map { try self.toEntityMapper.map($0) }
        default:
            query.fatalError(.put, self)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [E], in query: Query) -> Future<[E]> {
        switch query {
        case is PutQuery:
            return realmHandler.write { realm -> [O] in
                let objetcs = try array.map { try toRealmMapper.map($0, inRealm:realm) }
                objetcs.forEach { realm.add($0, update: true) }
                return objetcs
                }.map { try self.toEntityMapper.map($0) }
        default:
            query.fatalError(.putAll, self)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as IdQuery<String>:
            return realmHandler.write { realm in
                if let object = realm.object(ofType: O.self, forPrimaryKey: query.id) {
                    realm.delete(object)
                }
                return Void()
            }
        case let query as IdQuery<Int>:
            return realmHandler.write { realm in
                if let object = realm.object(ofType: O.self, forPrimaryKey: query.id) {
                    realm.delete(object)
                }
                return Void()
            }
        case let query as ObjectQuery<E>:
            return realmHandler.write { realm in
                if query.value.id == nil {
                    throw CoreError.IllegalArgument("The object Id must be not nil")
                }
                let object = try toRealmMapper.map(query.value, inRealm: realm)
                realm.delete(object)
                return Void()
            }
        default:
            query.fatalError(.delete, self)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as ObjectsQuery<E>:
            return realmHandler.write { realm in
                try query.values
                    .map { try toRealmMapper.map($0, inRealm: realm) }
                    .forEach { realm.delete($0) }
                return Void()
                }
        case is AllObjectsQuery:
            return realmHandler.write { realm in
                realm.objects(O.self).forEach { realm.delete($0) }
                return Void()
                }
        case let query as RealmQuery:
            return realmHandler.write { realm in
                realm.objects(O.self).filter(query.realmPredicate).forEach { realm.delete($0) }
                return Void()
                }
        default:
            query.fatalError(.deleteAll, self)
        }
    }
}
