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

public enum DelayDataSourceStyle {
    case sync
    case async(DispatchQueue)
}

public class DelayDataSource <D,T> : GetDataSource, PutDataSource, DeleteDataSource where D: GetDataSource, D:PutDataSource, D:DeleteDataSource, D.T == T {
    
    private let dataSource : D
    private let delay : TimeInterval
    private let style : DelayDataSourceStyle
    
    public init(_ dataSource: D, delay: TimeInterval, style : DelayDataSourceStyle = .sync) {
        self.dataSource = dataSource
        self.delay = delay
        self.style = style
    }
    
    public func get(_ query: Query) -> Future<T> {
        switch style {
        case .sync:
            return dataSource.get(query).withBlockingDelay(delay)
        case .async(let queue):
            return dataSource.get(query).withDelay(delay, queue: queue)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        switch style {
        case .sync:
            return dataSource.getAll(query).withBlockingDelay(delay)
        case .async(let queue):
            return dataSource.getAll(query).withDelay(delay, queue: queue)
        }
        
    }
    
    public func put(_ value: T?, in query: Query) -> Future<T> {
        switch style {
        case .sync:
            return dataSource.put(value, in: query).withBlockingDelay(delay)
        case .async(let queue):
            return dataSource.put(value, in: query).withDelay(delay, queue: queue)
        }
    }
    
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        switch style {
        case .sync:
            return dataSource.putAll(array, in: query).withBlockingDelay(delay)
        case .async(let queue):
            return dataSource.putAll(array, in: query).withDelay(delay, queue: queue)
        }
    }
    
    public func delete(_ query: Query) -> Future<Void> {
        switch style {
        case .sync:
            return dataSource.delete(query).withBlockingDelay(delay)
        case .async(let queue):
            return dataSource.delete(query).withDelay(delay, queue: queue)
        }
    }
    
    public func deleteAll(_ query: Query) -> Future<Void> {
        switch style {
        case .sync:
            return dataSource.deleteAll(query).withBlockingDelay(delay)
        case .async(let queue):
            return dataSource.deleteAll(query).withDelay(delay, queue: queue)
        }
    }
}
