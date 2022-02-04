//
// Copyright 2019 Mobile Jazz SL
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

fileprivate func print(_ object: String) {
    #if DEBUG
    Swift.print(object)
    #endif
}

///
/// The TimedCacheDataSource is KeyQuery-based data source, wrapper of another data source and acting as a fast cache.
/// It uses the date time of the access to cache the values, acting as a TLRU cache.
///
public class TimedCacheDataSource<T,D> : GetDataSource, PutDataSource, DeleteDataSource where D : GetDataSource, D : PutDataSource, D : DeleteDataSource, D.T == T {
    
    private let dataSource : D
    private let expiryInterval: TimeInterval
    
    private var objects : [String : (object: T, date: Date)] = [:]
    private var arrays : [String : (array:[T], date: Date)] = [:]
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The DataSource to cache.
    ///   - expiryInterval: The expiry interval used in the cache. Default value is 300 seconds (5 minutes).
    public init(_ dataSource : D, expiryInterval: TimeInterval = 300) {
        self.dataSource = dataSource
        self.expiryInterval = expiryInterval
    }
    
    private func isValid(_ date : Date) -> Bool {
        return date.timeIntervalSinceNow <= expiryInterval
    }
    
    public func get(_ query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            if let cached = objects[query.key], isValid(cached.date) {
                return Future(cached.object)
            }
            return dataSource.get(query).then { object in
                self.objects[query.key] = (object, Date())
                }.fail { error in
                    self.objects[query.key] = nil
            }
        default:
            print("TimedCacheDataSource can't cache the result of the \(type(of: dataSource)).get call because \(type(of: query)) doesn't conform to KeyQuery.")
            return dataSource.get(query)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        switch query {
        case let query as KeyQuery:
            if let cached = arrays[query.key], isValid(cached.date) {
                return Future(cached.array)
            }
            return dataSource.getAll(query).then { array in
                self.arrays[query.key] = (array, Date())
                }.fail { error in
                    self.arrays[query.key] = nil
            }
        default:
            print("TimedCacheDataSource can't cache the result of the \(type(of: dataSource)).getAll call because \(type(of: query)) doesn't conform to KeyQuery.")
            return dataSource.getAll(query)
        }
    }
    
    @discardableResult
    public func put(_ value: T? = nil, in query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            return dataSource.put(value, in: query).then { object in
                self.objects[query.key] = (object, Date())
                }.fail { error in
                    self.objects[query.key] = nil
            }
        default:
            print("TimedCacheDataSource can't cache the result of the \(type(of: dataSource)).put call because \(type(of: query)) doesn't conform to KeyQuery.")
            return dataSource.put(value, in: query)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        switch query {
        case let query as KeyQuery:
            return dataSource.putAll(array, in: query).then { array in
                self.arrays[query.key] = (array, Date())
                }.fail { error in
                    self.arrays[query.key] = nil
            }
        default:
            print("TimedCacheDataSource can't cache the result of the \(type(of: dataSource)).putAll call because \(type(of: query)) doesn't conform to KeyQuery.")
            return dataSource.putAll(array, in: query)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            return dataSource.delete(query).onCompletion {
                self.objects[query.key] = nil
            }
        default:
            print("TimedCacheDataSource can't cache the result of the \(type(of: dataSource)).delete call because \(type(of: query)) doesn't conform to KeyQuery.")
            return dataSource.delete(query)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            return dataSource.delete(query).onCompletion {
                self.arrays[query.key] = nil
            }
        default:
            print("TimedCacheDataSource can't cache the result of the \(type(of: dataSource)).deleteAll call because \(type(of: query)) doesn't conform to KeyQuery.")
            return dataSource.deleteAll(query)
        }
    }
}

