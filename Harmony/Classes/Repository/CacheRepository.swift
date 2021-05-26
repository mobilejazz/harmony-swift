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

/// MainOperation: Data processing will only use the "main data source".
public class MainOperation : Operation { public init () { } }

/// MainSyncOperation: Data processing will use the "main data source" and then sync result with the "cache data source".
public class MainSyncOperation : Operation { public init () { } }

/// CacheOperation: Data processing will only use the "cache data source".
public class CacheOperation : Operation {
    fileprivate let ignoreValidation: Bool
    
    /// Main initializer
    ///
    /// - Parameter ignoreValidation: A flag indicating if validation must be ignored.
    public init(ignoreValidation: Bool = false) {
        self.ignoreValidation = ignoreValidation
    }
}


/// CacheSyncOperation: Data processing will use the "cache data source" and sync with the "main data source".
///
/// If fallback returns true, then in case of network error, the repository will return the cached
/// data independently of it's validity.
public class CacheSyncOperation : Operation {
    fileprivate let fallback : (Error) -> Bool
    
    /// Main initializer
    ///
    /// - Parameter fallback: The fallback closure containg the error. Default value returns false.
    public init(fallback: @escaping (Error) -> Bool = { _ in false }) {
        self.fallback = fallback
    }
    /// Convenience initializer
    ///
    /// - Parameter fallback: The fallback behavior.
    public convenience init(fallback: Bool) {
        self.init(fallback: { _ in fallback })
    }
}

///
/// Repository containing two data sources: a fast-access data source and a slow-access data source.
///
/// Using the `MainOperation`, `MainSyncOperation`, `CacheOperation` and `CacheSyncOperation`, the end user can access the fast or slow data source.
/// A typical example of usage is using this repository to alternate between a network-based data source (main data source) and a local cache storage data source (cache data source).
///
/// Note that by using the `DefaultOperation`, the CacheRepository will act as a regular cache: behaving as a `CacheSyncOperation` on GET methods and behaving as a `MainSyncOperation` on PUT and DELETE methods.
///
public class CacheRepository<M,C,T> : GetRepository, PutRepository, DeleteRepository where M:GetDataSource, M:PutDataSource, M:DeleteDataSource, C:GetDataSource, C:PutDataSource, C:DeleteDataSource, M.T == T, C.T == T {
    
    private let main : M
    private let cache : C
    private let validator : ObjectValidation
    
    /// Main initializer
    ///
    /// - Parameters:
    ///   - main: The main data source
    ///   - cache: The cache data source
    ///   - validator: The cache validator object. Default value is an all-object is valid validator.
    public init(main: M, cache: C, validator: ObjectValidation = DefaultObjectValidation()) {
        self.main = main
        self.cache = cache
        self.validator = validator
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case is DefaultOperation:
            return get(query, operation: CacheSyncOperation())
        case is MainOperation:
            return main.get(query)
        case let op as CacheOperation:
            return cache
                .get(query)
                .filter { value in
                    if !self.validator.isObjectValid(value) {
                        if !op.ignoreValidation {
                            throw CoreError.NotValid()
                        }
                    }
                }
        case is MainSyncOperation:
            return main.get(query).flatMap { entity in
                return self.cache.put(entity, in: query)
            }
        case let op as CacheSyncOperation:
            var cachedValue: T!
            return cache
                .get(query)
                .filter { value in
                    if !self.validator.isObjectValid(value) {
                        cachedValue = value
                        throw CoreError.NotValid()
                    }
                }
                .recover { error in
                    switch error {
                    case is CoreError.NotValid, is CoreError.NotFound:
                        return self.get(query, operation: MainSyncOperation())
                            .recover { error in
                                if op.fallback(error) {
                                    if let cached = cachedValue {
                                        return Future(cached)
                                    } else {
                                        return Future(CoreError.NotFound())
                                    }
                                } else {
                                    return Future(error)
                                }
                        }
                    default:
                        return Future(error)
                    }
            }
        default:
            operation.fatalError(.get, self)
        }
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case is DefaultOperation:
            return getAll(query, operation: CacheSyncOperation())
        case is MainOperation:
            return main.getAll(query)
        case let op as CacheOperation:
            return cache
                .getAll(query)
                .filter { array in
                    if !self.validator.isArrayValid(array) {
                        if !op.ignoreValidation {
                            throw CoreError.NotValid()
                        }
                    }
                }
        case is MainSyncOperation:
            return main.getAll(query).flatMap { entities in
                return self.cache.putAll(entities, in: query)
            }
        case let op as CacheSyncOperation:
            var cachedValues: [T]!
            return cache
                .getAll(query)
                .filter { array in
                    cachedValues = array
                    if !self.validator.isArrayValid(array) {
                        throw CoreError.NotValid()
                    }
                }
                .recover { error in
                    switch error {
                    case is CoreError.NotValid, is CoreError.NotFound:
                        return self.getAll(query, operation: MainSyncOperation())
                            .recover { error in
                                if op.fallback(error) {
                                    if let cached = cachedValues {
                                        return Future(cached)
                                    } else {
                                        return Future(CoreError.NotFound())
                                    }
                                } else {
                                    return Future(error)
                                }
                        }
                    default:
                        return Future(error)
                    }
            }
        default:
            operation.fatalError(.getAll, self)
        }
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        switch operation {
        case is DefaultOperation:
            return put(value, in: query, operation: MainSyncOperation())
        case is MainOperation:
            return main.put(value, in: query)
        case is CacheOperation:
            return cache.put(value, in: query)
        case is MainSyncOperation:
            return main.put(value, in: query).flatMap { value in
                return self.cache.put(value, in: query)
            }
        case is CacheSyncOperation:
            return cache.put(value, in: query).flatMap { value in
                return self.main.put(value, in: query)
            }
        default:
            operation.fatalError(.put, self)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        switch operation {
        case is DefaultOperation:
            return putAll(array, in: query, operation: MainSyncOperation())
        case is MainOperation:
            return main.putAll(array, in: query)
        case is CacheOperation:
            return cache.putAll(array, in: query)
        case is MainSyncOperation:
            return main.putAll(array, in: query).flatMap { array in
                return self.cache.putAll(array, in: query)
            }
        case is CacheSyncOperation:
            return cache.putAll(array, in: query).flatMap { array in
                return self.main.putAll(array, in: query)
            }
        default:
            operation.fatalError(.putAll, self)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case is DefaultOperation:
            return delete(query, operation: MainSyncOperation())
        case is MainOperation:
            return main.delete(query)
        case is CacheOperation:
            return cache.delete(query)
        case is MainSyncOperation:
            return main.delete(query).flatMap {
                return self.cache.delete(query)
            }
        case is CacheSyncOperation:
            return cache.delete(query).flatMap {
                return self.main.delete(query)
            }
        default:
            operation.fatalError(.delete, self)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        switch operation {
        case is DefaultOperation:
            return deleteAll(query, operation: MainSyncOperation())
        case is MainOperation:
            return main.deleteAll(query)
        case is CacheOperation:
            return cache.deleteAll(query)
        case is MainSyncOperation:
            return main.deleteAll(query).flatMap {
                return self.cache.deleteAll(query)
            }
        case is CacheSyncOperation:
            return cache.deleteAll(query).flatMap {
                return self.main.deleteAll(query)
            }
        default:
            operation.fatalError(.deleteAll, self)
        }
    }
}
