//
//  FutureFromAgnosticDataSourceWrapper.swift
//  Harmony
//
//  Created by Fran Montiel on 17/3/23.
//

import Foundation

/// Wrapper to transform an AgnosticDataSource to a DataSource using Futures
internal class FutureFromAgnosticDataSourceWrapper<D, T>: GetDataSource, PutDataSource, DeleteDataSource where D: AgnosticGetDataSource, D: AgnosticPutDataSource, D: AgnosticDeleteDataSource, D.T == T {
    
    let datasource: D
    
    init(datasource: D) {
        self.datasource = datasource
    }
    
    public func get(_ query: Query) -> Future<T> {
        do {
            return try Future(datasource.get(query))
        } catch {
            return Future(error)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        do {
            return try Future(datasource.getAll(query))
        } catch {
            return Future(error)
        }
    }
    
    @discardableResult
    public func put(_ value: T? = nil, in query: Query) -> Future<T> {
        do {
            return try Future(datasource.put(value, in: query))
        } catch {
            return Future(error)
        }
    }
    
    @discardableResult
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        do {
            return try Future(datasource.putAll(array, in: query))
        } catch {
            return Future(error)
        }
    }
    
    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        do {
            return try Future(datasource.delete(query))
        } catch {
            return Future(error)
        }
    }
    
    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        do {
            return try Future(datasource.deleteAll(query))
        } catch {
            return Future(error)
        }    }
}
