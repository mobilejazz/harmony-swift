//
// Copyright 2022 Mobile Jazz SL
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
@available(iOS 13.0.0, *)
public final class AsyncAnyGetRepository<T>: AsyncGetRepository {
    private let box: AsyncGetRepositoryBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - repository: The repository to abstract
    public init<R: AsyncGetRepository>(_ repository: R) where R.T == T {
        box = AsyncGetRepositoryBox(repository)
    }
    
    public func get(_ query: Query, operation: Operation) async throws -> T {
        try await box.get(query, operation: operation)
    }
    
    public func getAll(_ query: Query, operation: Operation) async throws -> [T] {
        try await box.getAll(query, operation: operation)
    }
}

///
/// This is an abstract class. Do not use it.
/// GetRepository base class defining a generic type T (which is unrelated to the associated type of the GetRepository protocol)
///
@available(iOS 13.0.0, *)
internal class AsyncGetRepositoryBoxBase<T>: AsyncGetRepository {
    func get(_ query: Query, operation: Operation) async throws -> T {
        fatalError("This method is abstract.")
    }
    
    func getAll(_ query: Query, operation: Operation) async throws -> [T] {
        fatalError("This method is abstract.")
    }
}

///
/// A repository box, which has as generic type a GetRepository and links the GetRepositoryBoxBase type T as the Base.T type.
///
@available(iOS 13.0.0, *)
internal class AsyncGetRepositoryBox<Base: AsyncGetRepository>: AsyncGetRepositoryBoxBase<Base.T> {
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func get(_ query: Query, operation: Operation) async throws -> T {
        try await base.get(query, operation: operation)
    }
    
    override func getAll(_ query: Query, operation: Operation) async throws -> [T] {
        try await base.getAll(query, operation: operation)
    }
}
