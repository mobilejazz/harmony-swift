//
//  RawSQLDataSourceTests.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 27.10.2022..
//

import XCTest
import Harmony
import SQLite
import Nimble

struct UserEntity: Codable, Equatable {
    let id: Int64
    let name: String?
    let email: String
}

let nameKey = "name"
let emailKey = "email"
let idKey = "id"

final class RawSQLDataSourceTests: XCTestCase {

    func test_get_by_idQuery_int64_successfully_returns_entity() throws {
        // Given
        let expectedEmail = "alice@mac.com"
        let tableName = "users"
        let expressions: [any SQLValueExpression] = [
            SQLTableColumn(name: emailKey, type: String.self),
            SQLTableColumn(name: nameKey, type: String.self, isTypeOptional: true),
            SQLTableColumn(name: idKey, type: Int64.self)]
        let connection = try Connection(.inMemory, readonly: false)
        let rowId = try insert([UserEntity(id: 0, name: nil, email: expectedEmail)], in: connection, tableName: tableName)
        let dataSource = try givenADataSource(connection: connection, tableName: tableName, expressions: expressions)
        
        // When
        let entity = try dataSource.get(IdQuery(rowId[0])).result.get()
        
        // Then
        expect(entity.name).to(beNil())
        expect(entity.email).to(equal(expectedEmail))
        expect(entity.id).to(equal(rowId[0]))
    }

    func test_get_by_idQuery_int_successfully_returns_entity() throws {
        // Given
        let expectedEmail = "alice@mac.com"
        let tableName = "users"
        let expressions: [any SQLValueExpression] = [
            SQLTableColumn(name: emailKey, type: String.self),
            SQLTableColumn(name: nameKey, type: String.self, isTypeOptional: true),
            SQLTableColumn(name: idKey, type: Int.self)]
        let connection = try Connection(.inMemory, readonly: false)
        let rowId = try insert([UserEntity(id: 0, name: nil, email: expectedEmail)], in: connection, tableName: tableName)
        let dataSource = try givenADataSource(connection: connection, tableName: tableName, expressions: expressions)
        
        // When
        let entity = try dataSource.get(IdQuery(rowId[0])).result.get()
        
        // Then
        expect(entity.name).to(beNil())
        expect(entity.email).to(equal(expectedEmail))
        expect(entity.id).to(equal(rowId[0]))
    }
    
    func test_get_fails_with_unsupported_id_query() throws {
        // Given
        let tableName = "users"
        let connection = try Connection(.inMemory, readonly: false)
        let dataSource = try givenADataSource(connection: connection, tableName: tableName, expressions: [])
        
        // Then
        expect { try dataSource.get(IdQuery<String>("test")).result.get() }.to(throwError(CoreError.QueryNotSupported()))
    }
    
    func test_get_fails_with_unsupported_query() throws {
        // Given
        let tableName = "users"
        let connection = try Connection(.inMemory, readonly: false)
        let dataSource = try givenADataSource(connection: connection, tableName: tableName, expressions: [])
        
        // Then
        expect { try dataSource.get(ObjectQuery<String>("test")).result.get() }.to(throwError(CoreError.QueryNotSupported()))
    }

    func test_get_all_by_idsQuery_int64_successfully_returns_entity() throws {
        // Given
        let tableName = "users"
        let expressions: [any SQLValueExpression] = [
            SQLTableColumn(name: emailKey, type: String.self),
            SQLTableColumn(name: nameKey, type: String.self, isTypeOptional: true),
            SQLTableColumn(name: idKey, type: Int64.self)]
        let connection = try Connection(.inMemory, readonly: false)
        let rowIds = try insert([UserEntity(id: 0, name: "roger", email: "roger@me.com"),
                                 UserEntity(id: 0, name: "steve", email: "steve@me.com"),
                                 UserEntity(id: 0, name: "anne", email: "anne@me.com")
                                ], in: connection, tableName: tableName)

        let dataSource = try givenADataSource(connection: connection, tableName: tableName, expressions: expressions)
        
        // When
        let entities = try dataSource.getAll(IdsQuery(rowIds)).result.get()
        
        // Then
        expect(entities).to(equal([
            UserEntity(id: rowIds[0], name: "roger", email: "roger@me.com"),
            UserEntity(id: rowIds[1], name: "steve", email: "steve@me.com"),
            UserEntity(id: rowIds[2], name: "anne", email: "anne@me.com")
        ]))
    }
//    func test_get_fails_if_expressions_dont_match() throws {
//        // Given
//        let expectedEmail = "alice@mac.com"
//        let tableName = "users"
//        let expressions: [any SQLValueExpression] = [
//            SQLTableColumn(name: "address", type: String.self),
//            SQLTableColumn(name: "code", type: String.self),
//            SQLTableColumn(name: idKey, type: Int64.self)]
//        let connection = try Connection(.inMemory, readonly: false)
//        let rowId = try insert(UserEntity(id: 0, name: nil, email: expectedEmail), in: connection, tableName: tableName)
//        let dataSource = try givenADataSource(connection: connection, tableName: tableName, expressions: expressions)
//
//        // When
//        let entity = dataSource.get(IdQuery(rowId)).fail { error in
//            print()
//        }
//    }
}

private extension RawSQLDataSourceTests {
    func insert(_ entities: [UserEntity], in connection: Connection, tableName: String) throws -> [Int64] {
        let users = Table(tableName)
        let id = SQLite.Expression<Int64>(idKey)
        let name = SQLite.Expression<String?>(nameKey)
        let email = SQLite.Expression<String>(emailKey)
        
        try connection.run(users.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(email, unique: true)
        })
        var ids: [Int64] = []
        for entity in entities {
            let insertOp = users.insert(name <- entity.name, email <- entity.email)
            ids.append(try connection.run(insertOp))
        }
        
        return ids
    }
    
    func givenADataSource(connection: Connection, tableName: String, expressions: [any SQLValueExpression]) throws -> RawSQLDataSource<UserEntity> {
        guard let dataSource = RawSQLDataSource(dbConnection: connection,
                                                tableName: tableName,
                                                mapper: DataToDecodableMapper<UserEntity>(),
                                                expressions: expressions,
                                                logger: VoidLogger())
        else {
            throw CoreError.Failed()
        }
        return dataSource
    }
}