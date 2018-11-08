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
/// A type eraser for the GetRepository type, following Apple's Swift Standard Library approach.
///
public final class AnyGetRepository <T> : GetRepository {
    
    private let box: GetRepositoryBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - repository: The repository to abstract
    public init<R: GetRepository>(_ repository: R) where R.T == T {
        box = GetRepositoryBox(repository)
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        return box.get(query, operation: operation)
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        return box.getAll(query, operation: operation)
    }
}

extension GetRepository {
    /// Returns an AnyGetRepository abstraction of the current repository
    ///
    /// - Returns: An AnyGetRepository abstraction
    public func asAnyGetRepository() -> AnyGetRepository<T> {
        if let repo = self as? AnyGetRepository<T> {
            return repo
        }
        return AnyGetRepository(self)
    }
}

///
/// This is an abstract class. Do not use it.
/// GetRepository base class defining a generic type T (which is unrelated to the associated type of the GetRepository protocol)
///
internal class GetRepositoryBoxBase <T>: GetRepository {
    
    func get(_ query: Query, operation: Operation) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
}

///
/// A repository box, which has as generic type a GetRepository and links the GetRepositoryBoxBase type T as the Base.T type.
///
internal class GetRepositoryBox <Base: GetRepository> : GetRepositoryBoxBase <Base.T> {
    
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
}
