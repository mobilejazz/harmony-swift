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
/// This data source uses mappers to map objects and redirects them to the contained data source, acting as a simple "translator".
///
public class DataSourceMapper<From,To> : DataSource<From> {

    private let dataSource : DataSource<To>
    private let toToMapper: Mapper<From,To>
    private let toFromMapper: Mapper<To,From>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained dataSource
    ///   - toToMapper: From to To mapper
    ///   - toFromMapper: To to From mapper
    public init(dataSource: DataSource<To>,
                toToMapper: Mapper <From,To>,
                toFromMapper: Mapper<To,From>) {
        self.dataSource = dataSource
        self.toToMapper = toToMapper
        self.toFromMapper = toFromMapper
    }
    
    public override func get(_ query: Query) -> Future<From?> {
        return dataSource.get(query).map { value in
            if let value = value {
                return self.toFromMapper.map(value)
            }
            return nil
        }
    }
    
    public override func getAll(_ query: Query) -> Future<[From]> {
        return dataSource.getAll(query).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func put(_ value: From, in query: Query) -> Future<From> {
        return dataSource.put(toToMapper.map(value), in: query).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func putAll(_ array: [From], in query: Query) -> Future<[From]> {
        return dataSource.putAll(toToMapper.map(array), in: query).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func delete(_ value: From?, in query: Query) -> Future<Bool> {
        if let value = value {
            return dataSource.delete(toToMapper.map(value), in: query)
        }
        return dataSource.delete(nil, in: query)
    }
    
    @discardableResult
    public override func deleteAll(_ array: [From], in query: Query) -> Future<Bool> {
        return dataSource.deleteAll(toToMapper.map(array), in: query)
    }
    
}
