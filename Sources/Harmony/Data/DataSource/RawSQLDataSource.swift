//
//  RawSQLDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 22.09.2022..
//

import Foundation
import SQLite

public protocol QueryParam {
    associatedtype T
    var value: T {get}
}

public struct Expression<T>  {
    public let value: T
}

public protocol SQLInterface {
    associatedtype T
    
    func query<T>(query: String, parameters: [any QueryParam]?) -> Future<T>
    func findOne(sql: String, params: [any QueryParam]) -> T
    func findAll(sql: String, params: [any QueryParam]) -> [T]
    func insert(sql: String, params: [any QueryParam]) -> String
    func transaction(sql: String, params: [any QueryParam]) -> Bool
    func startTransaction()
    func endTransaction()
    func rollbackTransaction()
}

public class SQLQuery {
    init() {}
    func select() -> SQLQuery { SQLQuery() }
    func from(_ tableName: String) -> SQLQuery {SQLQuery() }
    func `where`<T>(column: String, hasValue: Expression<T>) -> SQLQuery {SQLQuery() }
    func limit(_ limit: Int) -> SQLQuery {SQLQuery() }
    func compile() -> SQLQuery {SQLQuery() }
    func sql() -> String { "" }
    func params() -> [any QueryParam] { [] }
}

public protocol SqlSchema {
    var tableName: String {get}
    var idColum: String {get}
    var keyColumn: String {get}
    var softDeleteEnabled: Bool {get}
}

public class QueryFactory {
    init() {}
    func select(colums: [String] = []) -> SQLQuery {SQLQuery() }
    func selectDistinct(colums: [String])  -> SQLQuery {SQLQuery() }
    func insert(table: String, map: [String: Any]) -> SQLQuery {SQLQuery() }
    func delete(table: String) -> SQLQuery {SQLQuery() }
    func update(table: String, map: [String: Any]) -> SQLQuery {SQLQuery() }
}

public class SQLBuilder {
    
    let schema: SqlSchema
    let factory: QueryFactory
    
    public init(squema: SqlSchema, factory: QueryFactory) {
        self.schema = squema
        self.factory = factory
    }
    
    public func selectByKey<T>(value: Expression<T>) -> SQLQuery {
        return selectOneWhere(column: schema.keyColumn, value: value)
    }

    public func selectById<T>(value: Expression<T>) -> SQLQuery {
        return selectOneWhere(column: schema.idColum, value: value);
    }

    public func selectOneWhere<T>(column: String, value: Expression<T>) -> SQLQuery {
        return factory
            .select()
            .from(schema.tableName)
            .where(column: column, hasValue: value)
            .limit(1)
            .compile()
      }
}


public let BaseColumnId = "id"
public let BaseColumnCreatedAt = "created_at"
public let BaseColumnUpdatedAt = "updated_at"
public let BaseColumnDeletedAt = "deleted_at"

public typealias RawSQLData = [String: Any]

public final class RawSQLDataSource<T, SQLI: SQLInterface>: GetDataSource, PutDataSource, DeleteDataSource where SQLI.T == T {
    
    private let sqlInterface: SQLI
    private let sqlBuilder: SQLBuilder
    private let tableName: String
    
    // TODO
    private var tableColumns: [String]
    
    private let idColumn: String
    private let createdAtColumn: String
    private let updatedAtColumn: String
    private let deletedAtColumn: String
    private let softDeleteEnabled: Bool
    private let logger: Logger
    
    init(sqlInterface: SQLI,
         sqlBuilder: SQLBuilder,
         tableName: String,
         columns: [String],
         createdAtColumn: String = BaseColumnCreatedAt,
         updatedAtColumn: String = BaseColumnUpdatedAt,
         deletedAtColumn: String = BaseColumnDeletedAt,
         softDeleteEnabled: Bool = false,
         logger: Logger) {
        self.sqlInterface = sqlInterface
        self.sqlBuilder = sqlBuilder
        self.tableName = tableName
        self.idColumn = BaseColumnId
        self.createdAtColumn = createdAtColumn
        self.updatedAtColumn = updatedAtColumn
        self.deletedAtColumn = deletedAtColumn
        self.softDeleteEnabled = softDeleteEnabled
        self.logger = logger
        self.tableColumns = columns + [createdAtColumn, updatedAtColumn];
    }
    
    // MARK: - GetDataSource
    
    public func get(_ query: Query) -> Future<T> {
        let sqlQuery: SQLQuery
        if let query = query as? IdQuery<String> {
            sqlQuery = sqlBuilder.selectById(value: Expression(value: query.id))
        } else if let query = query as? KeyQuery {
            sqlQuery = sqlBuilder.selectByKey(value: Expression(value: query.key))
        } else {
            return Future(CoreError.QueryNotSupported())
        }
        
        return Future(sqlInterface.findOne(sql: sqlQuery.sql(), params: sqlQuery.params()))
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        fatalError()
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
    
    private func columnsQuery() -> String {
        ([idColumn] + tableColumns).joined(separator: ", ")
    }
    
    private func selectSQL() -> String {
        "select \(columnsQuery()) from \(tableName)"
    }
}
