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

public class AnyDataSource <T> : DataSource {
    private let box: DataSourceBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - dataSource: The dataSource to abstract
    public init<D: DataSource>(_ dataSource: D) where D.T == T {
        box = DataSourceBox(dataSource)
    }
    
    public func get(_ query: Query) -> Future<T> {
        return box.get(query)
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        return box.getAll(query)
    }
    
    public func put(_ value: T?, in query: Query) -> Future<T> {
        return box.put(value, in: query)
    }
    
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return box.putAll(array, in: query)
    }
    
    public func delete(_ query: Query) -> Future<Void> {
        return box.delete(query)
    }
    
    public func deleteAll(_ query: Query) -> Future<Void> {
        return box.deleteAll(query)
    }
}

extension DataSource {
    /// Returns an AnyDataSource abstraction of the current data source
    ///
    /// - Returns: An AnyDataSource abstraction
    public func asAnyDataSource() -> AnyDataSource<T> {
        return AnyDataSource(self)
    }
}

///
/// This is an abstract class. Do not use it.
/// DataSource base class defining a generic type T (which is unrelated to the associated type of the DataSource protocol)
///
fileprivate class DataSourceBoxBase <T>: DataSource {
    
    func get(_ query: Query) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func getAll(_ query: Query) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func put(_ value: T?, in query: Query) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func delete(_ query: Query) -> Future<Void> {
        fatalError("This method is abstract.")
    }
    
    func deleteAll(_ query: Query) -> Future<Void> {
        fatalError("This method is abstract.")
    }
}

///
/// A data source box, which has as generic type a DataSource and links the DataSourceBoxBase type T as the Base.T type.
///
fileprivate class DataSourceBox <Base> : DataSourceBoxBase <Base.T> where Base : DataSource {
    
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
    
    override func put(_ value: T?, in query: Query) -> Future<T> {
        return base.put(value, in: query)
    }
    
    override func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return base.putAll(array, in: query)
    }
    
    override func delete(_ query: Query) -> Future<Void> {
        return base.delete(query)
    }
    
    override func deleteAll(_ query: Query) -> Future<Void> {
        return base.deleteAll(query)
    }
}
