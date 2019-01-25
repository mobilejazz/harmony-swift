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

public protocol Repository { }

public protocol GetRepository : Repository {
    
    associatedtype T
    
    /// Get a single method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of an optional repository's type
    func get(_ query: Query, operation: Operation) -> Future<T>
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    func getAll(_ query: Query, operation: Operation) -> Future<[T]>
}

extension GetRepository {
    public func get<K>(_ id: K, operation: Operation) -> Future<T> where K:Hashable {
        return get(IdQuery(id), operation: operation)
    }
    
    public func getAll<K>(_ id: K, operation: Operation) -> Future<[T]> where K:Hashable {
        return getAll(IdQuery(id), operation: operation)
    }
    
    public func toGetByQueryInteractor(_ executor: Executor) -> Interactor.GetByQuery<T> {
        return Interactor.GetByQuery(executor, self)
    }
    
    public func toGetInteractor(_ executor: Executor, _ query : Query) -> Interactor.Get<T> {
        return Interactor.Get<T>(executor, self, query)
    }
    
    public func toGetInteractor<K>(_ executor: Executor, _ id : K) -> Interactor.Get<T> where K:Hashable {
        return Interactor.Get<T>(executor, self, id)
    }
    
    public func toGetAllByQueryInteractor(_ executor: Executor) -> Interactor.GetAllByQuery<T> {
        return Interactor.GetAllByQuery(executor, self)
    }
    
    public func toGetAllInteractor(_ executor: Executor, _ query : Query) -> Interactor.GetAll<T> {
        return Interactor.GetAll<T>(executor, self, query)
    }
    
    public func toGetAllInteractor<K>(_ executor: Executor, _ id : K) -> Interactor.GetAll<T> where K:Hashable {
        return Interactor.GetAll<T>(executor, self, id)
    }
}

public protocol PutRepository : Repository {
    
    associatedtype T
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func put(_ value: T?, in query: Query, operation: Operation) -> Future<T>
    
    /// Put by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A future of T type. Some data sources might add some extra fields after the put operation, e.g. id or timestamp fields.
    @discardableResult
    func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]>
}

extension PutRepository {
    @discardableResult
    public func put<K>(_ value: T?, forId id: K, operation: Operation) -> Future<T> where K:Hashable {
        return put(value, in: IdQuery(id), operation: operation)
    }
    
    @discardableResult
    public func putAll<K>(_ array: [T], forId id: K, operation: Operation) -> Future<[T]> where K:Hashable {
        return putAll(array, in: IdQuery(id), operation: operation)
    }
    
    public func toPutByQueryInteractor(_ executor: Executor) -> Interactor.PutByQuery<T> {
        return Interactor.PutByQuery(executor, self)
    }
    
    public func toPutInteractor(_ executor: Executor, _ query : Query) -> Interactor.Put<T> {
        return Interactor.Put<T>(executor, self, query)
    }
    
    public func toPutInteractor<K>(_ executor: Executor, _ id : K) -> Interactor.Put<T> where K:Hashable {
        return Interactor.Put<T>(executor, self, id)
    }
    
    public func toPutAllByQueryInteractor(_ executor: Executor) -> Interactor.PutAllByQuery<T> {
        return Interactor.PutAllByQuery(executor, self)
    }
    
    public func toPutAllInteractor(_ executor: Executor, _ query : Query) -> Interactor.PutAll<T> {
        return Interactor.PutAll<T>(executor, self, query)
    }
    
    public func toPutAllInteractor<K>(_ executor: Executor, _ id : K) -> Interactor.PutAll<T> where K:Hashable {
        return Interactor.PutAll<T>(executor, self, id)
    }
}

public protocol DeleteRepository : Repository {
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Void type.
    @discardableResult
    func delete(_ query: Query, operation: Operation) -> Future<Void>
    
    /// Delete by query method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Void type.
    @discardableResult
    func deleteAll(_ query: Query, operation: Operation) -> Future<Void>
}

extension DeleteRepository {
    @discardableResult
    public func delete<K>(_ id: K, operation: Operation) -> Future<Void> where K:Hashable {
        return delete(IdQuery(id), operation: operation)
    }
    
    @discardableResult
    public func deleteAll<K>(_ id: K, operation: Operation) -> Future<Void> where K:Hashable {
        return deleteAll(IdQuery(id), operation: operation)
    }
    
    public func toDeleteByQueryInteractor<T>(_ executor: Executor) -> Interactor.DeleteByQuery<T> {
        return Interactor.DeleteByQuery<T>(executor, self)
    }
    
    public func toDeleteInteractor<T>(_ executor: Executor, _ query : Query) -> Interactor.Delete<T> {
        return Interactor.Delete<T>(executor, self, query)
    }
    
    public func toDeleteInteractor<T,K>(_ executor: Executor, _ id : K) -> Interactor.Delete<T> where K:Hashable {
        return Interactor.Delete<T>(executor, self, id)
    }
    
    public func toDeleteAllByQueryInteractor<T>(_ executor: Executor) -> Interactor.DeleteAllByQuery<T> {
        return Interactor.DeleteAllByQuery<T>(executor, self)
    }
    
    public func toDeleteAllInteractor<T>(_ executor: Executor, _ query : Query) -> Interactor.DeleteAll<T> {
        return Interactor.DeleteAll<T>(executor, self, query)
    }
    
    public func toDeleteAllInteractor<T,K>(_ executor: Executor, _ id : K) -> Interactor.DeleteAll<T> where K:Hashable {
        return Interactor.DeleteAll<T>(executor, self, id)
    }
}

public enum RepositoryCRUD : CustomStringConvertible {
    case get
    case getAll
    case put
    case putAll
    case delete
    case deleteAll
    
    public var description: String {
        switch self {
        case .get: return "get"
        case .getAll: return "getAll"
        case .put: return "put"
        case .putAll: return "putAll"
        case .delete: return "delete"
        case .deleteAll: return "deleteAll"
        }
    }
}

extension Operation {
    public func fatalError<R>(_ method: RepositoryCRUD, _ origin: R) -> Never where R : Repository {
        Swift.fatalError("Undefined operation \(String(describing: self)) for method \(method) on \(String(describing: type(of: origin)))")
    }
}
