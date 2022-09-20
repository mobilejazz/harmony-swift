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
/// A type eraser for the Repository type, following Apple's Swift Standard Library approach.
///
public final class AnyRepository <T> : GetRepository, PutRepository, DeleteRepository {
    
    private let box: RepositoryBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - repository: The repository to abstract
    public init<R>(_ repository: R) where R:GetRepository, R:PutRepository, R:DeleteRepository, R.T == T {
        box = RepositoryBox(repository)
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        return box.get(query, operation: operation)
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        return box.getAll(query, operation: operation)
    }
    
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return box.put(value, in: query, operation: operation)
    }
    
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return box.putAll(array, in: query, operation: operation)
    }
    
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return box.delete(query, operation: operation)
    }
    
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return box.deleteAll(query, operation: operation)
    }
}

///
/// This is an abstract class. Do not use it.
/// Repository base class defining a generic type T (which is unrelated to the associated type of the Repository protocol)
///
internal class RepositoryBoxBase <T>: GetRepository, PutRepository, DeleteRepository {
    
    func get(_ query: Query, operation: Operation) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func delete(_ query: Query, operation: Operation) -> Future<Void> {
        fatalError("This method is abstract.")
    }
    
    func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        fatalError("This method is abstract.")
    }
}

///
/// A repository box, which has as generic type a Repository and links the RepositoryBoxBase type T as the Base.T type.
///
internal class RepositoryBox <Base> : RepositoryBoxBase <Base.T> where Base:GetRepository, Base:PutRepository, Base:DeleteRepository {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func get(_ query: Query, operation: Operation) -> Future<T> {
        return base.get(query, operation: operation)
    }
    
    override func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        return base.getAll(query, operation: operation)
    }
    
    override func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return base.put(value, in: query, operation: operation)
    }
    
    override func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return base.putAll(array, in: query, operation: operation)
    }
    
    override func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return base.delete(query, operation: operation)
    }
    
    override func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return base.deleteAll(query, operation: operation)
    }
}
