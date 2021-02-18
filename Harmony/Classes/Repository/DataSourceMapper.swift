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
/// This data source uses mappers to map objects and redirects them to the contained data source, acting as a simple "translator".
///
public class GetDataSourceMapper <D: GetDataSource,In,Out> : GetDataSource where D.T == In {
    
    public typealias T = Out
    
    private let dataSource : D
    private let toOutMapper: Mapper<In,Out>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained dataSource
    ///   - toOutMapper: In to Out mapper
    public init(dataSource: D,
                toOutMapper: Mapper<In,Out>) {
        self.dataSource = dataSource
        self.toOutMapper = toOutMapper
    }
    
    public func get(_ query: Query) -> Future<Out> {
        return dataSource.get(query).map { value in
            return try self.toOutMapper.map(value)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[Out]> {
        return dataSource.getAll(query).map { try self.toOutMapper.map($0) }
    }
}

extension GetDataSource {
    func withMapping<K>(_ toOutMapper: Mapper<T,K>) -> GetDataSourceMapper<Self,T,K> {
        return GetDataSourceMapper(dataSource: self, toOutMapper: toOutMapper)
    }
}

///
/// This data source uses mappers to map objects and redirects them to the contained data source, acting as a simple "translator".
///
public class PutDataSourceMapper <D: PutDataSource,In,Out> : PutDataSource where D.T == In {
    
    public typealias T = Out
    
    private let dataSource : D
    private let toInMapper: Mapper<Out,In>
    private let toOutMapper: Mapper<In,Out>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained dataSource
    ///   - toInMapper: Out to In mapper
    ///   - toOutMapper: In to Out mapper
    public init(dataSource: D,
                toInMapper: Mapper<Out,In>,
                toOutMapper: Mapper<In,Out>) {
        self.dataSource = dataSource
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }
    
    @discardableResult
    public func put(_ value: Out?, in query: Query) -> Future<Out> {
        return Future(future: {
            var mapped : In? = nil
            if let value = value {
                mapped = try toInMapper.map(value)
            }
            return dataSource.put(mapped, in: query).map { try self.toOutMapper.map($0) }
        })
    }
    
    @discardableResult
    public func putAll(_ array: [Out], in query: Query) -> Future<[Out]> {
        return Future { dataSource.putAll(try toInMapper.map(array), in: query).map { try self.toOutMapper.map($0) } }
    }
}

extension PutDataSource {
    func withMapping<K>(in toInMapper: Mapper<K,T>, out toOutMapper: Mapper<T,K>) -> PutDataSourceMapper<Self,T,K> {
        return PutDataSourceMapper(dataSource: self, toInMapper: toInMapper, toOutMapper: toOutMapper)
    }
}

///
/// This data source uses mappers to map objects and redirects them to the contained data source, acting as a simple "translator".
///
public class DataSourceMapper <D,In,Out> : GetDataSource, PutDataSource, DeleteDataSource  where D:GetDataSource, D:PutDataSource, D:DeleteDataSource, D.T == In {
    
    public typealias T = Out

    private let dataSource : D
    private let toInMapper: Mapper<Out,In>
    private let toOutMapper: Mapper<In,Out>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained dataSource
    ///   - toInMapper: Out to In mapper
    ///   - toOutMapper: In to Out mapper
    public init(dataSource: D,
                toInMapper: Mapper<Out,In>,
                toOutMapper: Mapper<In,Out>) {
        self.dataSource = dataSource
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }
    
    public func get(_ query: Query) -> Future<Out> {
        return dataSource.get(query).map { value in
            return try self.toOutMapper.map(value)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[Out]> {
        return dataSource.getAll(query).map { try self.toOutMapper.map($0) }
    }
    
    @discardableResult
    public func put(_ value: Out?, in query: Query) -> Future<Out> {
        return Future(future: {
            var mapped : In? = nil
            if let value = value {
                mapped = try toInMapper.map(value)
            }
            return dataSource.put(mapped, in: query).map { try self.toOutMapper.map($0) }
        })
    }
    
    @discardableResult
    public func putAll(_ array: [Out], in query: Query) -> Future<[Out]> {
        return Future { dataSource.putAll(try toInMapper.map(array), in: query).map { try self.toOutMapper.map($0) } }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        return dataSource.delete(query)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        return dataSource.deleteAll(query)
    }
}
