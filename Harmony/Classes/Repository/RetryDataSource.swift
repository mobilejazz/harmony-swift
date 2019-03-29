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
/// A retry data source adds retry capabilities over an existing data source.
///
public class RetryDataSource <D,T> : GetDataSource, PutDataSource, DeleteDataSource where D:GetDataSource, D:PutDataSource, D:DeleteDataSource, D.T == T {
    
    private let dataSource : D
    private let retryCount : Int
    private let retryIf : (Error) -> Bool
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - dataSource: The data source to retry
    ///   - retryCount: The number of retries. Default value is 1.
    ///   - retryIf: A closure to evaluate each retry error. Return true to allow a retry, false otherwise. Default closure returns true.
    public init(_ dataSource: D,
                retryCount: Int = 1,
                retryIf : @escaping (Error) -> Bool = { _ in true }) {
        self.dataSource = dataSource
        self.retryCount = retryCount
        self.retryIf = retryIf
    }
    
    public func get(_ query: Query) -> Future<T> {
        return get(query, retryCount)
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        return getAll(query, retryCount)
    }
    
    @discardableResult
    public func put(_ value: T?, in query: Query) -> Future<T> {
        return put(value, in: query, retryCount)
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return putAll(array, in: query, retryCount)
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        return delete(query, retryCount)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        return deleteAll(query, retryCount)
    }
}

extension RetryDataSource {
    
    private func retry<K>(_ it: Int, _ error: Error, _ closure: () -> Future<K>) -> Future<K> {
        // Must retry if:
        //  - it is greater than zero
        //  - The retryIf closure returns true
        if it > 0 && retryIf(error) {
            return closure()
        }
        return Future(error)
    }
    
    private func get(_ query: Query, _ it: Int) -> Future<T> {
        return dataSource.get(query).recover { error in
            return self.retry(it, error) {
                return self.get(query, it - 1)
            }
        }
    }
    
    private func getAll(_ query: Query, _ it: Int) -> Future<[T]> {
        return dataSource.getAll(query).recover { error in
            return self.retry(it, error) {
                return self.getAll(query, it - 1)
            }
        }
    }
    
    private func put(_ value: T?, in query: Query, _ it: Int) -> Future<T> {
        return dataSource.put(value, in: query).recover { error in
            return self.retry(it, error) {
                return self.put(value, in: query, it - 1)
            }
        }
    }
    
    private func putAll(_ array: [T], in query: Query, _ it: Int) -> Future<[T]> {
        return dataSource.putAll(array, in: query).recover { error in
            return self.retry(it, error) {
                return self.putAll(array, in: query, it - 1)
            }
        }
    }
    
    private func delete(_ query: Query, _ it: Int) -> Future<Void> {
        return dataSource.delete(query).recover { error in
            return self.retry(it, error) {
                return self.delete(query, it - 1)
            }
        }
    }
    
    private func deleteAll(_ query: Query, _ it: Int) -> Future<Void> {
        return dataSource.deleteAll(query).recover { error in
            return self.retry(it, error) {
                return self.deleteAll(query, it - 1)
            }
        }
    }
}
