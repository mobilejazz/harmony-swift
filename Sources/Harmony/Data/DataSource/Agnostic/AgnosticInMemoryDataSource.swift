//
//  AgnosticInMemoryDataSource.swift
//  Harmony-iOS
//
//  Created by Fran Montiel on 17/3/23.
//

import Foundation

public class AgnosticInMemoryDataSource<T>: AgnosticGetDataSource, AgnosticPutDataSource, AgnosticDeleteDataSource {
    
    private var objects: [String: T] = [:]
    private var arrays: [String: [T]] = [:]
    
    public init() {}
    
    public func get(_ query: Query) throws -> T {
        switch query {
        case let query as KeyQuery:
            guard let value = objects[query.key] else {
                throw CoreError.NotFound()
            }
            return value
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func getAll(_ query: Query) throws -> [T] {
        switch query {
        case is AllObjectsQuery:
            var array = Array(objects.values)
            arrays.values.forEach { a in
                array.append(contentsOf: a)
            }
            return array
        case let query as IdsQuery<String>:
            return objects
                .filter { query.ids.contains($0.key) }
                .map { $0.value }
        case let query as KeyQuery:
            if let value = arrays[query.key] {
                return value
            }
            throw CoreError.NotFound()
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func put(_ value: T?, in query: Query) throws -> T {
        switch query {
        case let query as KeyQuery:
            guard let value = value else {
                throw CoreError.IllegalArgument("Value cannot be nil")
            }
            arrays.removeValue(forKey: query.key)
            objects[query.key] = value
            return value
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func putAll(_ array: [T], in query: Query) throws -> [T] {
        switch query {
        case let query as IdsQuery<String>:
            guard array.count == query.ids.count else {
                throw CoreError.IllegalArgument("Array lenght must be equal to query.ids length")
            }
            array.enumerated().forEach { offset, element in
                arrays.removeValue(forKey: query.ids[offset])
                objects[query.ids[offset]] = element
            }
            return array
        case let query as KeyQuery:
            objects.removeValue(forKey: query.key)
            arrays[query.key] = array
            return array
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    public func delete(_ query: Query) throws {
        switch query {
        case is AllObjectsQuery:
            objects.removeAll()
            arrays.removeAll()
        case let query as IdsQuery<String>:
            query.ids.forEach { key in
                objects.removeValue(forKey: key)
                arrays.removeValue(forKey: key)
            }
        case let query as KeyQuery:
            objects.removeValue(forKey: query.key)
            arrays.removeValue(forKey: query.key)
        default:
            throw CoreError.QueryNotSupported()
        }
    }
    
    func deleteAll(_ query: Query) throws {
        try delete(query)
    }
}
