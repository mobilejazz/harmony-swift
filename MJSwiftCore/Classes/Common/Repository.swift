//
// Copyright 2017 Mobile Jazz SL
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

/// Default query interface
public protocol Query { }

/// A query by an id
public class QueryById : Query {
    public let id : String
    public init (_ id: String) {
        self.id = id
    }
}

/// Abstract definition of a repository
open class Repository<T> {
    
    public init() { }
    
    /// Main get method
    ///
    /// - Parameter query: An instance conforming to Query that encapsules the get query information
    /// - Returns: A Future of the repository's type
    open func get(_ query: Query) -> Future<[T]> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method get on \(String(describing: type(of:self)))")
    }
    
    /// Main put method
    ///
    /// - Parameter entities: A list of entities to put
    /// - Returns: A future containing the list of updated entites after the put is resolved
    @discardableResult
    open func put(_ entities: [T]) -> Future<[T]> {
        fatalError("Undefined implementation for method put on \(String(describing: type(of:self)))")
    }
    
    /// Main delete method
    ///
    /// - Parameter query: An instance conforming to Query that encapusles the delete query information
    /// - Returns: A future of Boolean type. If the operation succeeds, the future will be resolved as true.
    @discardableResult
    open func delete(_ query: Query) -> Future<Bool> {
        fatalError("Undefined query class \(String(describing: type(of:query))) for method delete on \(String(describing: type(of:self)))")
    }
}

extension Repository {
    
    /// Custom put method for a single instnace
    ///
    /// - Parameter entity: The entity to put
    /// - Returns: A future containing the entity after the put is resolved
    @discardableResult
    open func put(_ entity: T) -> Future<T> {
        return self.put([entity]).map({ (entities) -> T in
            return entities.first!
        })
    }
}
