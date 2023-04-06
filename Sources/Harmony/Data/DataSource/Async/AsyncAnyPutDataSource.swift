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
// WITHOUT WADDANTIES OD CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

///
/// A type eraser for the PutDataSource type, following Apple's Swift Standard Library approach.
///
@available(iOS 13.0.0, *)
public final class AsyncAnyPutDataSource<T>: AsyncPutDataSource {
    private let box: AsyncPutDataSourceBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - dataSource: The dataSource to abstract
    public init<D: AsyncPutDataSource>(_ dataSource: D) where D.T == T {
        box = AsyncPutDataSourceBox(dataSource)
    }
    
    public func put(_ value: T?, in query: Query) async throws -> T {
        try await box.put(value, in: query)
    }
    
    public func putAll(_ array: [T], in query: Query) async throws -> [T] {
        try await box.putAll(array, in: query)
    }
}

///
/// This is an abstract class. Do not use it.
/// PutDataSource base class defining a generic type T (which is unrelated to the associated type of the PutDataSource protocol)
///
@available(iOS 13.0.0, *)
internal class AsyncPutDataSourceBoxBase<T>: AsyncPutDataSource {
    func put(_ value: T?, in query: Query) async throws -> T {
        fatalError("This method is abstract.")
    }
    
    func putAll(_ array: [T], in query: Query) async throws -> [T] {
        fatalError("This method is abstract.")
    }
}

///
/// A dataSource box, which has as generic type a PutDataSource and links the PutDataSourceBoxBase type T as the Base.T type.
///
@available(iOS 13.0.0, *)
internal class AsyncPutDataSourceBox<Base: AsyncPutDataSource>: AsyncPutDataSourceBoxBase<Base.T> {
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func put(_ value: T?, in query: Query) async throws -> T {
        try await base.put(value, in: query)
    }
    
    override func putAll(_ array: [T], in query: Query) async throws -> [T] {
        try await base.putAll(array, in: query)
    }
}
