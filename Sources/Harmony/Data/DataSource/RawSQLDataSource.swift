//
//  RawSQLDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 22.09.2022..
//

import Foundation
import SQLite

public let BaseColumnId = "id"
public let BaseColumnCreatedAt = "created_at"
public let BaseColumnUpdatedAt = "updated_at"
public let BaseColumnDeletedAt = "deleted_at"

public typealias RawSQLData = [String: Any]

public final class RawSQLDataSource<T: Codable>: GetDataSource, PutDataSource, DeleteDataSource {
    
    private let dbConnection: Connection
    
    private let mapper = DataToDecodableMapper<T>()
    private let tableName: String
    private let idColumn: String
    private let createdAtColumn: String
    private let updatedAtColumn: String
    private let deletedAtColumn: String
    private let softDeleteEnabled: Bool
    private let logger: Logger
    private let expressions: [any SQLValueExpression]
    
    public init?(dbConnection: Connection,
                 tableName: String,
                 idColumn: String = BaseColumnId,
                 mapper: DataToDecodableMapper<T>,
                 expressions: [any SQLValueExpression],
                 createdAtColumn: String = BaseColumnCreatedAt,
                 updatedAtColumn: String = BaseColumnUpdatedAt,
                 deletedAtColumn: String = BaseColumnDeletedAt,
                 softDeleteEnabled: Bool = false,
                 logger: Logger) {
        self.expressions = expressions
        self.dbConnection = dbConnection
        self.tableName = tableName
        self.idColumn = idColumn
        self.createdAtColumn = createdAtColumn
        self.updatedAtColumn = updatedAtColumn
        self.deletedAtColumn = deletedAtColumn
        self.softDeleteEnabled = softDeleteEnabled
        self.logger = logger        
//        let properties = columns + [TableProperty(name: createdAtColumn, type: Date.self) as TableProperty<Any>,
//                                    TableProperty(name: updatedAtColumn, type: Date.self) as TableProperty<Any>]
    }
    
    // MARK: - GetDataSource
    
    public func get(_ query: Query) -> Future<T> {
        return Future { resolver in
            switch query {
            case let query as IdQuery<Int>:
                resolver.set(try getFirstById(query: query))
            case let query as IdQuery<Int64>:
                resolver.set(try getFirstById(query: query))
            default:
                resolver.set(CoreError.QueryNotSupported())
            }
        }
    }

    public func getAll(_ query: Query) -> Future<[T]> {
        return Future { resolver in
            switch query {
            case let query as IdsQuery<Int>:
                resolver.set(try getAllByIds(query: query))
            case let query as IdsQuery<Int64>:
                resolver.set(try getAllByIds(query: query))
            default:
                resolver.set(CoreError.QueryNotSupported())
            }
        }
    }
    
    // MARK: - PutDataSource
    
    public func put(_ value: T?, in query: Query) -> Future<T> {
        fatalError()
    }
    
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        fatalError()
    }
    
    // MARK: - DeleteDataSource
    
    public func delete(_ query: Query) -> Future<Void> {
        fatalError()
    }
    
    public func deleteAll(_ query: Query) -> Future<Void> {
        fatalError()
    }
}

// MARK: - Mapping
private extension RawSQLDataSource {
    
    func mappedObject(from row: Row, mapper: DataToDecodableMapper<T>) throws -> T {
        var results: [String: Any] = [:]
        for exp in expressions {
            if let value = try? getValue(expression: exp, row: row) {
                results[exp.identifier] = value
            }
        }
        let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
        return mapper.map(jsonData)
    }
    
    func getValue<VExp: SQLValueExpression>(expression: VExp, row: Row) throws -> VExp.V? where VExp.V: Value {
        if expression.isTypeOptional {
            let newExpression = mappedOptionalExpression(from: expression)
            return try row.get(newExpression)
        } else {
            let newExpression = mappedExpression(from: expression)
            return try row.get(newExpression)
        }
    }

    func mappedOptionalExpression<VExp: SQLValueExpression>(from expression: VExp) -> Expression<VExp.V?> {
        Expression<VExp.V?>(expression.identifier)
    }

    func mappedExpression<VExp: SQLValueExpression>(from expression: VExp) -> Expression<VExp.V> {
        Expression<VExp.V>(expression.identifier)
    }
}

// MARK: - Get Helpers
private extension RawSQLDataSource {
    func getFirstById<K>(query: IdQuery<K>) throws -> T where K: Value, K.Datatype: Equatable {
        guard let first = try getAllById(query: query).first else { throw CoreError.NotFound() }
        return first
    }
    
    func getAllById<K>(query: IdQuery<K>) throws -> [T] where K: Value, K.Datatype: Equatable {
        let table = Table(tableName)
        let idColumn = SQLite.Expression<K>(idColumn)
        let rows = try dbConnection.prepare(table.filter(idColumn == query.id))
        let results = try rows.map { row in
            try mappedObject(from: row, mapper: mapper)
        }

        return results
    }
    
    func getAllByIds<K>(query: IdsQuery<K>) throws -> [T] where K: Value, K.Datatype: Equatable {
        let table = Table(tableName)
        let idColumn = SQLite.Expression<K>(idColumn)
        let rows = try dbConnection.prepare(table.filter(query.ids.contains(idColumn)))
        let results = try rows.map { row in
            try mappedObject(from: row, mapper: mapper)
        }

        return results
    }
}
