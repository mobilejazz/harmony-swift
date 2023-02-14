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
/// A type eraser for the GetDataSource type, following Apple's Swift Standard Library approach.
///
@available(iOS 13.0.0, *)
public final class AsyncAnyGetDataSource<T>: AsyncGetDataSource {
    private let box: AsyncGetDataSourceBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - dataSource: The dataSource to abstract
    public init<D: AsyncGetDataSource>(_ dataSource: D) where D.T == T {
        box = AsyncGetDataSourceBox(dataSource)
    }
    
    public func get(_ query: Query) async throws -> T {
        try await box.get(query)
    }
    
    public func getAll(_ query: Query) async throws -> [T] {
        try await box.getAll(query)
    }
}

///
/// This is an abstract class. Do not use it.
/// GetDataSource base class defining a generic type T (which is unrelated to the associated type of the GetDataSource protocol)
///
@available(iOS 13.0.0, *)
internal class AsyncGetDataSourceBoxBase<T>: AsyncGetDataSource {
    func get(_ query: Query) async throws -> T {
        fatalError("This method is abstract.")
    }
    
    func getAll(_ query: Query) async throws -> [T] {
        fatalError("This method is abstract.")
    }
}

///
/// A dataSource box, which has as generic type a GetDataSource and links the GetDataSourceBoxBase type T as the Base.T type.
///
@available(iOS 13.0.0, *)
internal class AsyncGetDataSourceBox<Base: AsyncGetDataSource>: AsyncGetDataSourceBoxBase<Base.T> {
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func get(_ query: Query) async throws -> T {
        try await base.get(query)
    }
    
    override func getAll(_ query: Query) async throws -> [T] {
        try await base.getAll(query)
    }
}
