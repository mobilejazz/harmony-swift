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
/// Mapped data provider
///
public class MappedDataProvider<From,To> : DataProvider<From> {

    private let dataProvider : DataProvider<To>
    private let toToMapper: Mapper<From,To>
    private let toFromMapper: Mapper<To,From>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataProvider: The contained data provider
    ///   - toToMapper: From to To mapper
    ///   - toFromMapper: To to From mapper
    public init(dataProvider: DataProvider<To>,
                toToMapper: Mapper <From,To>,
                toFromMapper: Mapper<To,From>) {
        self.dataProvider = dataProvider
        self.toToMapper = toToMapper
        self.toFromMapper = toFromMapper
    }
    
    public override func getAll(_ query: Query, operation: Operation) -> Future<[From]> {
        return dataProvider.getAll(query.map(toToMapper)).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func put(_ query: Query, operation: Operation) -> Future<Bool> {
        return dataProvider.put(query.map(toToMapper))
    }
    
    @discardableResult
    public override func putAll(_ objects: [From], operation: Operation) -> Future<[From]> {
        return dataProvider.putAll(toToMapper.map(objects)).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func delete(_ query: Query, operation: Operation) -> Future<Bool> {
        return dataProvider.delete(query.map(toToMapper))
    }
    
    @discardableResult
    public override func deleteAll(_ objects: [From], operation: Operation) -> Future<Bool> {
        return dataProvider.deleteAll(toToMapper.map(objects))
    }
}
