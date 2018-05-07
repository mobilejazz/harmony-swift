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

public class SingleDataSourceRepository<T> : Repository<T> {

    private let dataSource : DataSource<T>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained data source
    public init(_ dataSource: DataSource<T>) {
        self.dataSource = dataSource
    }
    
    public override func get(_ query: Query, operation: Operation = .blank) -> Future<T?> {
        return dataSource.get(query)
    }
    
    public override func getAll(_ query: Query, operation: Operation = .blank) -> Future<[T]> {
        return dataSource.getAll(query)
    }
    
    public override func put(_ value: T, in query: Query, operation: Operation = .blank) -> Future<T> {
        return dataSource.put(value, in: query)
    }
    
    public override func putAll(_ array: [T], in query: Query, operation: Operation = .blank) -> Future<[T]> {
        return dataSource.putAll(array, in: query)
    }
    
    public override func delete(_ value: T?, in query: Query, operation: Operation = .blank) -> Future<Bool> {
        return dataSource.delete(value, in: query)
    }
    
    public override func deleteAll(_ array: [T], in query: Query, operation: Operation = .blank) -> Future<Bool> {
        return dataSource.deleteAll(array, in: query)
    }
}

extension DataSource {
    public func toRepository() -> SingleDataSourceRepository<T> {
        return SingleDataSourceRepository(self)
    }
}
