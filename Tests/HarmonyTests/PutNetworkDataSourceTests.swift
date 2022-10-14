//
//  PutNetworkDataSourceTests.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Alamofire
import Foundation
import Harmony
import Nimble
import XCTest

@available(iOS 13.0, *)
final class PutNetworkDataSourceTests: XCTestCase {

    private typealias Utils = GenericDataSourceUtils
    
    func test_putAll_allobjects_query_not_supported() {
        // Given
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: "")
        let query = AllObjectsQuery()
        
        // Then
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .putAll)
    }
    
    func test_putall_returns_no_response() {
        // Given
        let array = [Entity(name: "a", owner: "a"), Entity(name: "b", owner: "b")]
        let query = NetworkQuery(method: .post(type: .Json(entity: array)), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<NoResponse> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPutAll(value: [], dataSource, query, nil)
    }
    
    func test_putall_returns_illegal_argument_error_when_value_and_content_type_are_both_present() {
        // Given
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: "")
        let array = [Entity(name: "", owner: "")]
        let query = NetworkQuery(method: .put(type: .Json(entity: array)), path: "")
        
        // Then
        expectPutAllError(value: array, dataSource, query, CoreError.IllegalArgument(), .putAll)
    }
    
    func test_putall_returns_query_not_supported_error_when_query_method_not_put() {
        // Given
        let dataSource: PutNetworkDataSource<Int> = providePutDataSource(url: "")
        
        // Then
        expectPutError(dataSource, NetworkQuery(method: .get, path: ""), CoreError.QueryNotSupported(), .putAll)
        expectPutError(dataSource, NetworkQuery(method: .delete, path: ""), CoreError.QueryNotSupported(), .putAll)
    }

    func test_putall_returns_error_when_network_request_fails() {
        // Given
        let array = [Entity(name: "", owner: "")]
        let query = NetworkQuery(method: .put(type: .Json(entity: array)), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 400, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder)
        
        // Then
        expectPutAllAlamofireError(value: [], dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 400)))
    }
    
    func test_putall_returns_data_serialization_error_when_response_has_no_data() {
        // Given
        let array = [Entity(name: "", owner: "")]
        let query = NetworkQuery(method: .put(type: .Json(entity: array)), path: "")
        let url = "www.dummy.com"
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response)
        
        // Then
        expectPutError(dataSource, query, CoreError.DataSerialization(), .putAll)
    }

    func test_putall_returns_value_when_provided_as_parameter() {
        // Given
        let array = [Entity(name: "", owner: "")]
        let query = NetworkQuery(method: .put(type: nil), path: "")
        let url = "www.dummy.com"
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, jsonFileName: "EntityList")
        
        // Then
        expectPutAll(value: array, dataSource, query, nil)
    }

    func test_putall_returns_data_serialization_error_when_data_fails_to_be_parsed_as_generic_type() {
        // Given
        let query = NetworkQuery(method: .put(type: nil), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        decoder.forceFailure = true
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder)
        
        // Then
        expectPutAll(value: [Entity(name: "", owner: "")], dataSource, query, CoreError.DataSerialization())
    }
    
    // Validation
    func test_put_returns_query_not_supported_error_when_query_not_a_network_query() {
        // Given
        let dataSource: PutNetworkDataSource<Int> = providePutDataSource(url: "")
        let query = AllObjectsQuery()
        
        // Then
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .put)
    }

    func test_put_returns_query_not_supported_error_when_query_method_not_put() {
        // Given
        let dataSource: PutNetworkDataSource<Int> = providePutDataSource(url: "")
        let query = NetworkQuery(method: .get, path: "")
        
        // Then
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .put)
    }

    func test_put_returns_illegal_argument_error_when_value_and_content_type_are_both_present() {
        // Given
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: "")
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .put(type: .Json(entity: entity)), path: "")
        
        // Then
        expectPutError(value: entity, dataSource, query, CoreError.IllegalArgument(), .put)
    }

    func test_put_returns_error_when_network_request_fails() {
        // Given
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .put(type: .Json(entity: entity)), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 400, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder)
        
        // Then
        expectPutAlamofireError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 400)))
    }
    
    func test_put_returns_data_serialization_error_when_response_has_no_data() {
        // Given
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .put(type: .Json(entity: entity)), path: "")
        let url = "www.dummy.com"
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response)
        
        // Then
        expectPutError(dataSource, query, CoreError.DataSerialization(), .put)
    }

    func test_put_returns_value_when_provided_as_parameter() {
        // Given
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .put(type: nil), path: "")
        let url = "www.dummy.com"
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, jsonFileName: "Entity")
        
        // Then
        expectPut(value: entity, dataSource, query, nil)
    }

    func test_put_returns_data_serialization_error_when_data_fails_to_be_parsed_as_generic_type() {
        // Given
        let query = NetworkQuery(method: .put(type: nil), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        decoder.forceFailure = true
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPut(dataSource, query, CoreError.DataSerialization())
    }
    
    // MARK: Post
    
    func test_post_returns_illegal_argument_error_when_value_and_content_type_are_both_present() {
        // Given
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: "")
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .post(type: .Json(entity: entity)), path: "")
        
        // Then
        expectPutError(value: entity, dataSource, query, CoreError.IllegalArgument(), .put)
    }

    func test_post_returns_error_when_network_request_fails() {
        // Given
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .post(type: .Json(entity: entity)), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 400, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder)
        
        // Then
        expectPutAlamofireError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 400)))
    }
    
    func test_post_returns_data_serialization_error_when_response_has_no_data() {
        // Given
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .post(type: .Json(entity: entity)), path: "")
        let url = "www.dummy.com"
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response)
        
        // Then
        expectPutError(dataSource, query, CoreError.DataSerialization(), .put)
    }

    func test_post_returns_value_when_provided_as_parameter() {
        // Given
        let entity = Entity(name: "", owner: "")
        let query = NetworkQuery(method: .post(type: nil), path: "")
        let url = "www.dummy.com"
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, jsonFileName: "Entity")
        
        // Then
        expectPut(value: entity, dataSource, query, nil)
    }

    func test_post_returns_data_serialization_error_when_data_fails_to_be_parsed_as_generic_type() {
        // Given
        let query = NetworkQuery(method: .post(type: nil), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        decoder.forceFailure = true
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPut(dataSource, query, CoreError.DataSerialization())
    }
    
    func test_post_returns_no_response() {
        // Given
        let queryWithContentType = NetworkQuery(method: .post(type: .Json(entity: Entity(name: "", owner: ""))), path: "")
        let queryNoContentType = NetworkQuery(method: .post(type: nil), path: "")
        let url = "www.dummy.com"
        let decoder = DecoderSpy()
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        let dataSource: PutNetworkDataSource<NoResponse> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPut(value: NoResponse(), dataSource, queryNoContentType, nil)
        expectPut(value: nil, dataSource, queryWithContentType, nil)
    }
    
    private func expectPutAll<S: Decodable>(value: [S], _ dataSource: PutNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.putAll(value, in: query)
                .then { _ in
                    if expectedError == nil {
                        expectation.fulfill()
                    }
                }
                .fail { error in
                    if let expectedError = expectedError {
                        if type(of: error) == type(of: expectedError) {
                            expectation.fulfill()
                        }
                    }
                }

        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expectPut<S: Decodable>(value: S? = nil, _ dataSource: PutNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.put(value, in: query)
            .then { value in
                if expectedError == nil {
                    expectation.fulfill()
                }
            }
            .fail { error in
                if let expectedError = expectedError {
                    if type(of: error) == type(of: expectedError) {
                        expectation.fulfill()
                    }
                }
            }

        wait(for: [expectation], timeout: 1.0)
    }

    private func providePutDataSource<S: Decodable>(
        url: String,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil
    ) -> PutNetworkDataSource<S> {
        let session = Utils.provideMockAlamofireSession(request: request, response: response, jsonFileName: jsonFileName)
        return PutNetworkDataSource<S>(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }

    private func expectPutError<S: Decodable>(
        value: S? = nil,
        _ dataSource: PutNetworkDataSource<S>,
        _ query: Query,
        _ expectedError: Error?,
        _ function: Function)
    {
        if function == .putAll {
            expectPutAll(value: (value != nil) ? [value!] : [], dataSource, query, expectedError)
        } else {
            expectPut(value: value, dataSource, query, expectedError)
        }
    }
    
    private func expectPutAllError<S: Decodable>(
        value: [S],
        _ dataSource: PutNetworkDataSource<S>,
        _ query: Query,
        _ expectedError: Error?,
        _ function: Function)
    {
        expectPutAll(value: value, dataSource, query, expectedError)
    }
    
    private func expectPutAlamofireError<S: Decodable>(
            _ dataSource: PutNetworkDataSource<S>,
            _ query: Query,
            _ expectedError: AFError)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.put(nil, in: query).then { _ in
            print("")
        }.fail { error in
            if let error = error as? AFError {
                if error.localizedDescription == expectedError.localizedDescription {
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expectPutAllAlamofireError<S: Decodable>(
            value: [S],
            _ dataSource: PutNetworkDataSource<S>,
            _ query: Query,
            _ expectedError: AFError)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.putAll(value, in: query).then { _ in
            print("")
        }.fail { error in
            if let error = error as? AFError {
                if error.localizedDescription == expectedError.localizedDescription {
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
