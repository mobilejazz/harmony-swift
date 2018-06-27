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
/// A type eraser for the DeleteRepository type, following Apple's Swift Standard Library approach.
///
public class AnyDeleteRepository <T> : DeleteRepository {
    
    private let box: DeleteRepositoryBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - repository: The repository to abstract
    public init<R: DeleteRepository>(_ repository: R) where R.T == T {
        box = DeleteRepositoryBox(repository)
    }
    
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return box.delete(query, operation: operation)
    }
    
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return box.deleteAll(query, operation: operation)
    }
}

extension DeleteRepository {
    /// Returns an AnyDeleteRepository abstraction of the current repository
    ///
    /// - Returns: An AnyDeleteRepository abstraction
    public func asAnyDeleteRepository() -> AnyDeleteRepository<T> {
        if let repo = self as? AnyDeleteRepository<T> {
            return repo
        }
        return AnyDeleteRepository(self)
    }
}

///
/// This is an abstract class. Do not use it.
/// DeleteRepository base class defining a generic type T (which is unrelated to the associated type of the DeleteRepository protocol)
///
internal class DeleteRepositoryBoxBase <T>: DeleteRepository {

    func delete(_ query: Query, operation: Operation) -> Future<Void> {
        fatalError("This method is abstract.")
    }
    
    func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        fatalError("This method is abstract.")
    }
}

///
/// A repository box, which has as generic type a DeleteRepository and links the DeleteRepositoryBoxBase type T as the Base.T type.
///
internal class DeleteRepositoryBox <Base: DeleteRepository> : DeleteRepositoryBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return base.delete(query, operation: operation)
    }
    
    override func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return base.deleteAll(query, operation: operation)
    }
}
