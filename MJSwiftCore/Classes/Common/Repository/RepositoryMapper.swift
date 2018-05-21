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
/// This repository uses mappers to map objects and redirects them to the contained repository, acting as a simple "translator".
///
public class RepositoryMapper<From,To>: Repository<From> {
    
    private let repository : Repository<To>
    private let toToMapper: Mapper<From,To>
    private let toFromMapper: Mapper<To,From>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    ///   - toToMapper: From to To mapper
    ///   - toFromMapper: To to From mapper
    public init(repository: Repository<To>,
                toToMapper: Mapper <From,To>,
                toFromMapper: Mapper<To,From>) {
        self.repository = repository
        self.toToMapper = toToMapper
        self.toFromMapper = toFromMapper
    }
    
    public override func get(_ query: Query, operation: Operation) -> Future<From> {
        return repository.get(query, operation: operation).map { value in
            return self.toFromMapper.map(value)
        }
    }
    
    public override func getAll(_ query: Query, operation: Operation) -> Future<[From]> {
         return repository.getAll(query, operation: operation).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func put(_ value: From?, in query: Query, operation: Operation) -> Future<From> {
        var mapped : To? = nil
        if let value = value {
            mapped = toToMapper.map(value)
        }
        return repository.put(mapped, in: query, operation: operation).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func putAll(_ array: [From], in query: Query, operation: Operation) -> Future<[From]> {
        return repository.putAll(toToMapper.map(array), in: query, operation: operation).map { self.toFromMapper.map($0) }
    }
    
    @discardableResult
    public override func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return repository.delete(query, operation: operation)
    }
    
    @discardableResult
    public override func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return repository.deleteAll(query, operation: operation)
    }
}
