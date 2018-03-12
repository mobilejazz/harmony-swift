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
/// Basic data provider using only one repository internally
/// No operation is required in data provider's methods.
///
public class RepositoryDataProvider <E> : DataProvider <E> {
    
    private let repository : Repository<E>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    public init(repository: Repository<E>) {
        self.repository = repository
    }
    
    public override func getAll(_ query: Query, operation: Operation = .none) -> Future<[E]> {
        return repository.getAll(query)
    }
    
    public override func put(_ query: Query, operation: Operation = .none) -> Future<Bool> {
        return repository.put(query)
    }
    
    public override func putAll(_ objects: [E], operation: Operation = .none) -> Future<[E]> {
        return repository.putAll(objects)
    }
    
    public override func delete(_ query: Query, operation: Operation = .none) -> Future<Bool> {
        return repository.delete(query)
    }
    
    public override func deleteAll(_ objects: [E], operation: Operation = .none) -> Future<Bool> {
        return repository.deleteAll(objects)
    }
}
