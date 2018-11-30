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
import FirebaseFirestore
import MJSwiftCore

/// All objects used in a FirestoreDataSource will require to adopt this protocol.
public protocol FirestoreObject {
    /// The collection name
    static var collection : String { get }
}

/// A query interface for FirestoreDataSource.
/// Used in getAll, observeAll & deleteAll methods.
public protocol FirestoreQuery : MJSwiftCore.Query {
    /// The query composer method.
    /// Note this method has a default implementation that returns the input collection parameter.
    ///
    /// - Parameter collection: The collection where the query will be executed
    /// - Returns: A composed query to be excuted.
    func query(_ collection : CollectionReference) -> FirebaseFirestore.Query
}

public extension FirestoreQuery {
    func query(_ collection : CollectionReference) -> FirebaseFirestore.Query {
        return collection
    }
}

///
/// Get implementation for a FiresotreDataSource.
///
public class GetFirestoreDataSource<T> : GetDataSource where T : FirestoreObject {
    
    private let db : Firestore
    private let toObject : Mapper<[String : Any], T>
    
    /// The source used in get functions.
    public var source : FirestoreSource = .default
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - db: The Firestore instance.
    ///   - toObject: The mapper from dictionary to object.
    public init(_ db: Firestore, _ toObject: Mapper<[String : Any], T>) {
        self.db = db
        self.toObject = toObject
    }
    
    public func get(_ query: MJSwiftCore.Query) -> Future<T> {
        switch query {
        case let query as IdQuery<String>:
            return db.collection(T.collection).document(query.id).get(source: source)
                .map{ $0.data() }
                .unwrap()
                .map { try self.toObject.map($0) }
        case let query as IdQuery<Int>:
            return get(IdQuery<String>("\(query.id)"))
        case let query as IdQuery<UInt>:
            return get(IdQuery<String>("\(query.id)"))
        default:
            query.fatalError(.get, self)
        }
    }
    
    public func getAll(_ query: MJSwiftCore.Query) -> Future<[T]> {
        switch query {
        case let query as FirestoreQuery:
            return query.query(db.collection(T.collection)).get(source: source)
                .map { try $0.documents.map { try self.toObject.map($0.data()) } }
        case let query as IdQuery<[String]>:
            return Future.batch(query.id.map { get($0) })
        case let query as IdQuery<[Int]>:
            return getAll(IdQuery(query.id.map { "\($0)" }))
        case let query as IdQuery<[UInt]>:
            return getAll(IdQuery(query.id.map { "\($0)" }))
        default:
            query.fatalError(.getAll, self)
        }
    }
}

///
/// Observe implementation for a FiresotreDataSource.
///
public class ObserveFirestoreDataSource<T> : ObserveDataSource where T : FirestoreObject {
    
    private let db : Firestore
    private let toObject : Mapper<[String : Any], T>
    
    public var includeMetadataChanges : Bool = false
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - db: The Firestore instance.
    ///   - toObject: The mapper from dictionary to object.
    public init(_ db: Firestore, _ toObject: Mapper<[String : Any], T>) {
        self.db = db
        self.toObject = toObject
    }
    
    public func observe(_ query: MJSwiftCore.Query) -> Observable<T> {
        switch query {
        case let query as IdQuery<String>:
            return db.collection(T.collection).document(query.id).observe(includeMetadataChanges: includeMetadataChanges)
                .map{ $0.data() }
                .unwrap()
                .map { try self.toObject.map($0) }
        case let query as IdQuery<Int>:
            return observe(IdQuery("\(query.id)"))
        case let query as IdQuery<UInt>:
            return observe(IdQuery("\(query.id)"))
        default:
            query.fatalError(.get, self)
        }
    }
    
    public func observeAll(_ query: MJSwiftCore.Query) -> Observable<[T]> {
        switch query {
        case let query as FirestoreQuery:
            return query.query(db.collection(T.collection)).observe(includeMetadataChanges: includeMetadataChanges)
                .map { try $0.documents.map { try self.toObject.map($0.data()) } }
        case let query as IdQuery<[String]>:
            return Observable.batch(query.id.map { observe($0) })
        case let query as IdQuery<[Int]>:
            return observeAll(IdQuery(query.id.map { "\($0)" }))
        case let query as IdQuery<[UInt]>:
            return observeAll(IdQuery(query.id.map { "\($0)" }))
        default:
            query.fatalError(.getAll, self)
        }
    }
}

///
/// Put implementation for a FiresotreDataSource.
///
public class PutFirestoreDataSource<T> : PutDataSource where T : FirestoreObject {
    
    private let db : Firestore
    private let toObject : Mapper<[String : Any], T>
    private let toData : Mapper<T, [String : Any]>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - db: The Firestore instance.
    ///   - toObject: The mapper from dictionary to object.
    ///   - toData: The mapper from object to dictionary.
    public init(_ db: Firestore, _ toObject : Mapper<[String : Any], T>, _ toData : Mapper<T, [String : Any]>) {
        self.db = db
        self.toObject = toObject
        self.toData = toData
    }
    
    public func put(_ value: T?, in query: MJSwiftCore.Query) -> Future<T> {
        
        guard let value = value else { return Future(CoreError.IllegalArgument("Value must be not nil")) }
        
        switch query {
        case is VoidQuery:
            return Future(future: {
                let data = try toData.map(value)
                return db.collection(T.collection).put(data: data).map { value }
            })
        case let query as IdQuery<String>:
            return Future(future: {
                let data = try toData.map(value)
                return db.collection(T.collection).document(query.id).put(data: data).map { value }
            })
        case let query as IdQuery<Int>:
            return put(value, in: IdQuery("\(query.id)"))
        case let query as IdQuery<UInt>:
            return put(value, in: IdQuery("\(query.id)"))
        default:
            query.fatalError(.put, self)
        }
    }
    
    public func putAll(_ array: [T], in query: MJSwiftCore.Query) -> Future<[T]> {
        switch query {
        case let query as IdQuery<[String]>:
            return Future.batch(query.id.enumerated().map { (idx, id) in put(array[idx], forId: id) })
        case let query as IdQuery<[Int]>:
            return putAll(array, in: IdQuery(query.id.map { "\($0)" }))
        case let query as IdQuery<[UInt]>:
            return putAll(array, in: IdQuery(query.id.map { "\($0)" }))
        default:
            query.fatalError(.putAll, self)
        }
    }
}

///
/// Delete implementation for a FiresotreDataSource.
///
public class DeleteFirestoreDataSource<T> : DeleteDataSource where T : FirestoreObject {
    
    private let db : Firestore
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - db: The Firestore instance.
    public init(_ db: Firestore) {
        self.db = db
    }
    
    public func delete(_ query: MJSwiftCore.Query) -> Future<Void> {
        switch query {
        case let query as IdQuery<String>:
            return db.collection(T.collection).document(query.id).delete()
        case let query as IdQuery<Int>:
            return delete(IdQuery("\(query.id)"))
        case let query as IdQuery<UInt>:
            return delete(IdQuery("\(query.id)"))
        default:
            query.fatalError(.delete, self)
        }
    }
    
    public func deleteAll(_ query: MJSwiftCore.Query) -> Future<Void> {
        switch query {
        case let query as IdQuery<[String]>:
            return Future.batch(query.id.map { delete($0) }).map { _ in () }
        case let query as IdQuery<[Int]>:
            return deleteAll(IdQuery(query.id.map { "\($0)" }))
        case let query as IdQuery<[UInt]>:
            return deleteAll(IdQuery(query.id.map { "\($0)" }))
        default:
            query.fatalError(.deleteAll, self)
        }
    }
}

///
/// A Get, Observe, Put & Delete FirestoreDataSource implementation.
///
public class FirestoreDataSource<T> : GetDataSource, ObserveDataSource, PutDataSource, DeleteDataSource where T : FirestoreObject {

    public let get : GetFirestoreDataSource<T>
    public let observe : ObserveFirestoreDataSource<T>
    public let put : PutFirestoreDataSource<T>
    public let delete : DeleteFirestoreDataSource<T>
    
    init(_ db : Firestore, _ toObject : Mapper<[String : Any], T>, _ toData : Mapper<T, [String : Any]>) {
        self.get = GetFirestoreDataSource<T>(db, toObject)
        self.observe = ObserveFirestoreDataSource<T>(db, toObject)
        self.put = PutFirestoreDataSource<T>(db, toObject, toData)
        self.delete = DeleteFirestoreDataSource<T>(db)
    }
    
    public func get(_ query: MJSwiftCore.Query) -> Future<T> {
        return get.get(query)
    }
    
    public func observe(_ query: MJSwiftCore.Query) -> Observable<T> {
        return observe.observe(query)
    }
    
    public func put(_ value: T?, in query: MJSwiftCore.Query) -> Future<T> {
        return put.put(value, in: query)
    }
    
    public func delete(_ query: MJSwiftCore.Query) -> Future<Void> {
        return delete.delete(query)
    }
    
    public func getAll(_ query: MJSwiftCore.Query) -> Future<[T]> {
        return get.getAll(query)
    }
    
    public func observeAll(_ query: MJSwiftCore.Query) -> Observable<[T]> {
        return observe.observeAll(query)
    }
    
    public func putAll(_ array: [T], in query: MJSwiftCore.Query) -> Future<[T]> {
        return put.putAll(array, in: query)
    }
    
    public func deleteAll(_ query: MJSwiftCore.Query) -> Future<Void> {
        return delete.deleteAll(query)
    }
}
