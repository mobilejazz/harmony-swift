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

public class RepositoryDataProvider <O,E> : DataProvider <O> {
    
    private let repository : Repository<E>
    private let toEntityMapper: Mapper<O,E>
    private let toObjectMapper: Mapper<E,O>
    
    public init(repository: Repository<E>,
                toEntityMapper: Mapper <O,E>,
                toObjectMapper: Mapper<E,O>) {
        self.repository = repository
        self.toEntityMapper = toEntityMapper
        self.toObjectMapper = toObjectMapper
    }
    
    public override func getAll(_ query: Query, operation: Operation = .none) -> Future<[O]> {
        return repository.getAll(query.map(toEntityMapper)).map { a in self.toObjectMapper.map(a) }
    }
    
    public override func put(_ query: Query, operation: Operation = .none) -> Future<Bool> {
        return repository.put(query.map(toEntityMapper))
    }
    
    public override func putAll(_ objects: [O], operation: Operation = .none) -> Future<[O]> {
        let entities = toEntityMapper.map(objects)
        return repository.putAll(entities).map { a in self.toObjectMapper.map(a) }
    }
    
    public override func delete(_ query: Query, operation: Operation = .none) -> Future<Bool> {
        return repository.delete(query.map(toEntityMapper))
    }
    
    public override func deleteAll(_ objects: [O], operation: Operation = .none) -> Future<Bool> {
        let entities = toEntityMapper.map(objects)
        return repository.deleteAll(entities)
    }
}
