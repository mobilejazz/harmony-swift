//
//  NetworkQueryTests.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 01.11.2022..
//

import Harmony
import HarmonyTesting
import Nimble
import XCTest

final class NetworkQueryTests: XCTestCase {
    func test_method_with_content_type_throws_for_get() throws {
        // Given
        let get: NetworkQuery.Method = .get

        // Then
        expect { try get.with(contentType: nil) }.to(throwError())
    }

    func test_method_with_content_type_throws_for_delete() throws {
        // Given
        let delete: NetworkQuery.Method = .delete

        // Then
        expect { try delete.with(contentType: nil) }.to(throwError())
    }

    func test_method_with_content_type_replaces_type_for_post() throws {
        // Given
        var post: NetworkQuery.Method = .post(type: nil)
        let expectedEntity = EntityList()
        let expectedType = NetworkQuery.ContentType.Json(entity: expectedEntity)

        // When
        post = try post.with(contentType: expectedType)

        // Then
        try expectContentTypeToMatch(expectedEntity: expectedEntity, actualType: post.contentType())
    }

    func test_method_with_content_type_replaces_type_for_put() throws {
        // Given
        var put: NetworkQuery.Method = .put(type: nil)
        let expectedEntity = EntityList()
        let expectedType = NetworkQuery.ContentType.Json(entity: expectedEntity)

        // When
        put = try put.with(contentType: expectedType)

        // Then
        try expectContentTypeToMatch(expectedEntity: expectedEntity, actualType: put.contentType())
    }

    func test_content_type_returns_nil_for_get() throws {
        // Given
        let get: NetworkQuery.Method = .get

        // Then
        expect(get.contentType()).to(beNil())
    }

    func test_content_type_returns_nil_for_delete() throws {
        // Given
        let delete: NetworkQuery.Method = .delete

        // Then
        expect(delete.contentType()).to(beNil())
    }

    func test_content_type_returns_value_for_post() throws {
        // Given
        let expectedEntity = EntityList()
        let expectedType = NetworkQuery.ContentType.Json(entity: expectedEntity)
        let post: NetworkQuery.Method = .post(type: expectedType)

        // Then
        try expectContentTypeToMatch(expectedEntity: expectedEntity, actualType: post.contentType())
    }

    func test_content_type_returns_value_for_put() throws {
        // Given
        let expectedEntity = EntityList()
        let expectedType = NetworkQuery.ContentType.Json(entity: expectedEntity)
        let put: NetworkQuery.Method = .put(type: expectedType)

        // Then
        try expectContentTypeToMatch(expectedEntity: expectedEntity, actualType: put.contentType())
    }
}

private extension NetworkQueryTests {
    func expectContentTypeToMatch(expectedEntity: EntityList, actualType: NetworkQuery.ContentType?) throws {
        if case let .Json(entity: entity) = actualType {
            expect(entity as? EntityList).to(equal(expectedEntity))
        } else {
            XCTFail()
        }
    }
}
