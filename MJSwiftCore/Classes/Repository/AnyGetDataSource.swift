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
/// Type eraser class for DataSource, following Apple's Swift Standard Library approach.
///
public final class AnyGetDataSource <T> : GetDataSource {
    private let box: GetDataSourceBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - dataSource: The dataSource to abstract
    public init<D: GetDataSource>(_ dataSource: D) where D.T == T {
        box = GetDataSourceBox(dataSource)
    }
    
    public func get(_ query: Query) -> Future<T> {
        return box.get(query)
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        return box.getAll(query)
    }
}

extension GetDataSource {
    /// Returns an AnyGetDataSource abstraction of the current data source
    ///
    /// - Returns: An AnyGetDataSource abstraction
    public func asAnyGetDataSource() -> AnyGetDataSource<T> {
        if let dataSource = self as? AnyGetDataSource<T> {
            return dataSource
        }
        return AnyGetDataSource(self)
    }
}

///
/// This is an abstract class. Do not use it.
/// GetDataSource base class defining a generic type T (which is unrelated to the associated type of the GetDataSource protocol)
///
internal class GetDataSourceBoxBase <T>: GetDataSource {
    
    func get(_ query: Query) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func getAll(_ query: Query) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
}

///
/// A data source box, which has as generic type a GetDataSource and links the GetDataSourceBoxBase type T as the Base.T type.
///
internal class GetDataSourceBox <Base: GetDataSource> : GetDataSourceBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func get(_ query: Query) -> Future<T> {
        return base.get(query)
    }
    
    override func getAll(_ query: Query) -> Future<[T]> {
        return base.getAll(query)
    }
}
