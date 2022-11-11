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

struct UserEntity: Codable {
    let id: Int64
    let name: String?
    let email: String
}

let nameKey = "name"
let emailKey = "email"
let idKey = "id"

final class RawSQLDataSourceTests: XCTestCase {

    func test_get_successfully_returns_entity() throws {
        // Given
        let expectedEmail = "alice@mac.com"
        let tableName = "users"
        let expressions: [any SQLValueExpression] = [
            SQLTableColumn(name: emailKey, type: String.self),
            SQLTableColumn(name: nameKey, type: String.self, isTypeOptional: true),
            SQLTableColumn(name: idKey, type: Int64.self)]
        let connection = try Connection(.inMemory, readonly: false)
        let rowId = try insert(UserEntity(id: 0, name: nil, email: expectedEmail), in: connection, tableName: tableName)
        let dataSource = try givenADataSource(connection: connection, tableName: tableName, expressions: expressions)
        
        // When
        let entity = try dataSource.get(IdQuery(rowId)).result.get()
        
        // Then
        expect(entity.name).to(beNil())
        expect(entity.email).to(equal(expectedEmail))
        expect(entity.id).to(equal(rowId))
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
    func insert(_ user: UserEntity, in connection: Connection, tableName: String) throws -> Int64 {
        let users = Table(tableName)
        let id = SQLite.Expression<Int64>(idKey)
        let name = SQLite.Expression<String?>(nameKey)
        let email = SQLite.Expression<String>(emailKey)
        
        try connection.run(users.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(email, unique: true)
        })
        
        let insert = users.insert(name <- user.name, email <- user.email)
        return try connection.run(insert)
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
