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
public final class AnyPutDataSource <T> : PutDataSource {
    private let box: PutDataSourceBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - dataSource: The dataSource to abstract
    public init<D: PutDataSource>(_ dataSource: D) where D.T == T {
        box = PutDataSourceBox(dataSource)
    }
    
    public func put(_ value: T?, in query: Query) -> Future<T> {
        return box.put(value, in: query)
    }
    
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return box.putAll(array, in: query)
    }
}

extension PutDataSource {
    /// Returns an AnyPutDataSource abstraction of the current data source
    ///
    /// - Returns: An AnyPutDataSource abstraction
    public func asAnyPutDataSource() -> AnyPutDataSource<T> {
        if let dataSource = self as? AnyPutDataSource<T> {
            return dataSource
        }
        return AnyPutDataSource(self)
    }
}

///
/// This is an abstract class. Do not use it.
/// PutDataSource base class defining a generic type T (which is unrelated to the associated type of the PutDataSource protocol)
///
internal class PutDataSourceBoxBase <T>: PutDataSource {
    
    func put(_ value: T?, in query: Query) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
}

///
/// A data source box, which has as generic type a PutDataSource and links the PutDataSourceBoxBase type T as the Base.T type.
///
internal class PutDataSourceBox <Base: PutDataSource> : PutDataSourceBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func put(_ value: T?, in query: Query) -> Future<T> {
        return base.put(value, in: query)
    }
    
    override func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return base.putAll(array, in: query)
    }
}
