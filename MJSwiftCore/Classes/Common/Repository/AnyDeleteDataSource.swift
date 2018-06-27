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

public class AnyDeleteDataSource <T> : DeleteDataSource {
    private let box: DeleteDataSourceBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - dataSource: The dataSource to abstract
    public init<D: DeleteDataSource>(_ dataSource: D) where D.T == T {
        box = DeleteDataSourceBox(dataSource)
    }
    
    public func delete(_ query: Query) -> Future<Void> {
        return box.delete(query)
    }
    
    public func deleteAll(_ query: Query) -> Future<Void> {
        return box.deleteAll(query)
    }
}

extension DeleteDataSource {
    /// Returns an AnyDeleteDataSource abstraction of the current data source
    ///
    /// - Returns: An AnyDeleteDataSource abstraction
    public func asAnyDeleteDataSource() -> AnyDeleteDataSource<T> {
        if let dataSource = self as? AnyDeleteDataSource<T> {
            return dataSource
        }
        return AnyDeleteDataSource(self)
    }
}

///
/// This is an abstract class. Do not use it.
/// DeleteDataSource base class defining a generic type T (which is unrelated to the associated type of the DeleteDataSource protocol)
///
internal class DeleteDataSourceBoxBase <T>: DeleteDataSource {
    
    func delete(_ query: Query) -> Future<Void> {
        fatalError("This method is abstract.")
    }
    
    func deleteAll(_ query: Query) -> Future<Void> {
        fatalError("This method is abstract.")
    }
}

///
/// A data source box, which has as generic type a DeleteDataSource and links the DeleteDataSourceBoxBase type T as the Base.T type.
///
internal class DeleteDataSourceBox <Base: DeleteDataSource> : DeleteDataSourceBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func delete(_ query: Query) -> Future<Void> {
        return base.delete(query)
    }
    
    override func deleteAll(_ query: Query) -> Future<Void> {
        return base.deleteAll(query)
    }
}
