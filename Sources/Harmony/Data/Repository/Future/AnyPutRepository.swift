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
/// A type eraser for the PutRepository type, following Apple's Swift Standard Library approach.
///
public final class AnyPutRepository <T> : PutRepository {
    
    private let box: PutRepositoryBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - repository: The repository to abstract
    public init<R: PutRepository>(_ repository: R) where R.T == T {
        box = PutRepositoryBox(repository)
    }
    
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return box.put(value, in: query, operation: operation)
    }
    
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return box.putAll(array, in: query, operation: operation)
    }
}

extension PutRepository {
    /// Returns an AnyPutRepository abstraction of the current repository
    ///
    /// - Returns: An AnyPutRepository abstraction
    public func asAnyPutRepository() -> AnyPutRepository<T> {
        if let repo = self as? AnyPutRepository<T> {
            return repo
        }
        return AnyPutRepository(self)
    }
}

///
/// This is an abstract class. Do not use it.
/// PutRepository base class defining a generic type T (which is unrelated to the associated type of the PutRepository protocol)
///
internal class PutRepositoryBoxBase <T>: PutRepository {

    func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
}

///
/// A repository box, which has as generic type a PutRepository and links the PutRepositoryBoxBase type T as the Base.T type.
///
internal class PutRepositoryBox <Base: PutRepository> : PutRepositoryBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }

    override func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return base.put(value, in: query, operation: operation)
    }
    
    override func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return base.putAll(array, in: query, operation: operation)
    }
}
