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
/// This repository uses mappers to map objects and redirects them to the contained repository, acting as a simple "translator".
///
public class GetRepositoryMapper <R: GetRepository,In,Out> : GetRepository where R.T == In {
    
    public typealias T = Out
    
    private let repository : R
    private let toOutMapper: Mapper<In,Out>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    ///   - toOutMapper: In to Out mapper
    public init(repository: R,
                toOutMapper: Mapper<In,Out>) {
        self.repository = repository
        self.toOutMapper = toOutMapper
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<Out> {
        return repository.get(query, operation: operation).map { value in
            return try self.toOutMapper.map(value)
        }
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[Out]> {
        return repository.getAll(query, operation: operation).map { try self.toOutMapper.map($0) }
    }
}

extension GetRepository {
    func withMapping<K>(_ toOutMapper: Mapper<T,K>) -> GetRepositoryMapper<Self,T,K> {
        return GetRepositoryMapper(repository: self, toOutMapper: toOutMapper)
    }
}

///
/// This repository uses mappers to map objects and redirects them to the contained repository, acting as a simple "translator".
///
public class PutRepositoryMapper <R: PutRepository,Out,In> : PutRepository where R.T == In {
    
    public typealias T = Out
    
    private let repository : R
    private let toInMapper: Mapper<Out,In>
    private let toOutMapper: Mapper<In,Out>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    ///   - toInMapper: Out to In mapper
    ///   - toOutMapper: In to Out mapper
    public init(repository: R,
                toInMapper: Mapper<Out,In>,
                toOutMapper: Mapper<In,Out>) {
        self.repository = repository
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }
    
    @discardableResult
    public func put(_ value: Out?, in query: Query, operation: Operation) -> Future<Out> {
        return Future(future: {
            var mapped : In? = nil
            if let value = value {
                mapped = try toInMapper.map(value)
            }
            return repository.put(mapped, in: query, operation: operation).map { try self.toOutMapper.map($0) }
        })
    }
    
    @discardableResult
    public func putAll(_ array: [Out], in query: Query, operation: Operation) -> Future<[Out]> {
        return Future {
            return repository.putAll(try toInMapper.map(array), in: query, operation: operation).map { try self.toOutMapper.map($0) }
        }
    }
}

extension PutRepository {
    func withMapping<K>(in toInMapper: Mapper<K,T>, out toOutMapper: Mapper<T,K>) -> PutRepositoryMapper<Self,T,K> {
        return PutRepositoryMapper(repository: self, toInMapper: toInMapper, toOutMapper: toOutMapper)
    }
}

///
/// This repository uses mappers to map objects and redirects them to the contained repository, acting as a simple "translator".
///
public class RepositoryMapper <R,Out,In> : GetRepository, PutRepository, DeleteRepository where R:GetRepository, R:PutRepository, R:DeleteRepository, R.T == In {
    
    public typealias T = Out
    
    private let repository : R
    private let toInMapper: Mapper<Out,In>
    private let toOutMapper: Mapper<In,Out>
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - repository: The contained repository
    ///   - toInMapper: Out to In mapper
    ///   - toOutMapper: In to Out mapper
    public init(repository: R,
                toInMapper: Mapper<Out,In>,
                toOutMapper: Mapper<In,Out>) {
        self.repository = repository
        self.toInMapper = toInMapper
        self.toOutMapper = toOutMapper
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<Out> {
        return repository.get(query, operation: operation).map { value in
            return try self.toOutMapper.map(value)
        }
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[Out]> {
         return repository.getAll(query, operation: operation).map { try self.toOutMapper.map($0) }
    }
    
    @discardableResult
    public func put(_ value: Out?, in query: Query, operation: Operation) -> Future<Out> {
        return Future(future: {
            var mapped : In? = nil
            if let value = value {
                mapped = try toInMapper.map(value)
            }
            return repository.put(mapped, in: query, operation: operation).map { try self.toOutMapper.map($0) }
        })
    }
    
    @discardableResult
    public func putAll(_ array: [Out], in query: Query, operation: Operation) -> Future<[Out]> {
        return Future {
            return repository.putAll(try toInMapper.map(array), in: query, operation: operation).map { try self.toOutMapper.map($0) }
        }
    }
    
    @discardableResult
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return repository.delete(query, operation: operation)
    }
    
    @discardableResult
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return repository.deleteAll(query, operation: operation)
    }
}

