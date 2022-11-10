//
//  PutNetworkDataSourceTests.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation
import Harmony
import Nimble
import XCTest
import HarmonyTesting

@available(iOS 13.0, *)
final class PutNetworkDataSourceTests: XCTestCase {

    private typealias Utils = GenericDataSourceUtils
    
    func test_putAll_allobjects_query_not_supported() {
        // Given
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: anyURL())
        let query = AllObjectsQuery()
        
        // Then
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .putAll)
    }
    
    func test_putall_returns_no_response() {
        // Given
        let array = [anyEntity(), anyEntity()]
        let query = NetworkQuery(method: .post(type: .Json(entity: array)), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<NoResponse> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPutAll(value: [], dataSource, query, nil)
    }
    
    func test_putall_returns_illegal_argument_error_when_value_and_content_type_are_both_present() {
        // Given
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: anyURL())
        let array = [anyEntity()]
        let query = NetworkQuery(method: .put(type: .Json(entity: array)), path: anyString())
        
        // Then
        expectPutAllError(value: array, dataSource, query, CoreError.IllegalArgument(), .putAll)
    }
    
    func test_putall_returns_query_not_supported_error_when_query_method_not_put() {
        // Given
        let dataSource: PutNetworkDataSource<Int> = providePutDataSource(url: anyURL())
        
        // Then
        expectPutError(dataSource, NetworkQuery(method: .get, path: anyString()), CoreError.QueryNotSupported(), .putAll)
        expectPutError(dataSource, NetworkQuery(method: .delete, path: anyString()), CoreError.QueryNotSupported(), .putAll)
    }

    func test_putall_returns_error_when_network_request_fails() {
        // Given
        let array = [anyEntity()]
        let query = NetworkQuery(method: .put(type: .Json(entity: array)), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 400)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPutAllAlamofireError(value: [], dataSource, query, CoreError.Failed("HTTP status code: 400"))
    }
    
    func test_putall_returns_data_serialization_error_when_response_has_no_data() {
        // Given
        let array = [anyEntity()]
        let query = NetworkQuery(method: .put(type: .Json(entity: array)), path: anyString())
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response)
        
        // Then
        expectPutError(dataSource, query, CoreError.DataSerialization(), .putAll)
    }

    func test_putall_returns_value_when_provided_as_parameter() {
        // Given
        let array = [anyEntity()]
        let query = NetworkQuery(method: .put(type: nil), path: anyString())
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, jsonFileName: "EntityList")
        
        // Then
        expectPutAll(value: array, dataSource, query, nil)
    }

    func test_putall_returns_data_serialization_error_when_data_fails_to_be_parsed_as_generic_type() {
        // Given
        let query = NetworkQuery(method: .put(type: nil), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        decoder.forceFailure = true
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder)
        
        // Then
        expectPutAll(value: [anyEntity()], dataSource, query, CoreError.DataSerialization())
    }
    
    // Validation
    func test_put_returns_query_not_supported_error_when_query_not_a_network_query() {
        // Given
        let dataSource: PutNetworkDataSource<Int> = providePutDataSource(url: anyURL())
        let query = AllObjectsQuery()
        
        // Then
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .put)
    }

    func test_put_returns_query_not_supported_error_when_query_method_not_put() {
        // Given
        let dataSource: PutNetworkDataSource<Int> = providePutDataSource(url: anyURL())
        let query = NetworkQuery(method: .get, path: anyString())
        
        // Then
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .put)
    }

    func test_put_returns_illegal_argument_error_when_value_and_content_type_are_both_present() {
        // Given
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: anyURL())
        let entity = anyEntity()
        let query = NetworkQuery(method: .put(type: .Json(entity: entity)), path: anyString())
        
        // Then
        expectPutError(value: entity, dataSource, query, CoreError.IllegalArgument(), .put)
    }

    func test_put_returns_error_when_network_request_fails() {
        // Given
        let entity = anyEntity()
        let query = NetworkQuery(method: .put(type: .Json(entity: entity)), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 400)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPutAlamofireError(dataSource, query, CoreError.Failed("HTTP status code: 400"))
    }
    
    func test_put_returns_data_serialization_error_when_response_has_no_data() {
        // Given
        let entity = anyEntity()
        let query = NetworkQuery(method: .put(type: .Json(entity: entity)), path: anyString())
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response)
        
        // Then
        expectPutError(dataSource, query, CoreError.DataSerialization(), .put)
    }

    func test_put_returns_value_when_provided_as_parameter() {
        // Given
        let entity = anyEntity()
        let query = NetworkQuery(method: .put(type: nil), path: anyString())
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, jsonFileName: "Entity")
        
        // Then
        expectPut(value: entity, dataSource, query, nil)
    }

    func test_put_returns_data_serialization_error_when_data_fails_to_be_parsed_as_generic_type() {
        // Given
        let query = NetworkQuery(method: .put(type: nil), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        decoder.forceFailure = true
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPut(dataSource, query, CoreError.DataSerialization())
    }
    
    // MARK: Post
    
    func test_post_returns_illegal_argument_error_when_value_and_content_type_are_both_present() {
        // Given
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: anyURL())
        let entity: CodableEntity = anyEntity()
        let query = NetworkQuery(method: .post(type: .Json(entity: entity)), path: anyString())
        
        // Then
        expectPutError(value: entity, dataSource, query, CoreError.IllegalArgument(), .put)
    }

    func test_post_returns_error_when_network_request_fails() {
        // Given
        let entity = anyEntity()
        let query = NetworkQuery(method: .post(type: .Json(entity: entity)), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 400)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPutAlamofireError(dataSource, query, CoreError.Failed("HTTP status code: 400"))
    }
    
    func test_post_returns_data_serialization_error_when_response_has_no_data() {
        // Given
        let entity = anyEntity()
        let query = NetworkQuery(method: .post(type: .Json(entity: entity)), path: anyString())
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response)
        
        // Then
        expectPutError(dataSource, query, CoreError.DataSerialization(), .put)
    }

    func test_post_returns_value_when_provided_as_parameter() {
        // Given
        let entity = anyEntity()
        let query = NetworkQuery(method: .post(type: nil), path: anyString())
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, jsonFileName: "Entity")
        
        // Then
        expectPut(value: entity, dataSource, query, nil)
    }

    func test_post_returns_data_serialization_error_when_data_fails_to_be_parsed_as_generic_type() {
        // Given
        let query = NetworkQuery(method: .post(type: nil), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        decoder.forceFailure = true
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let dataSource: PutNetworkDataSource<CodableEntity> = providePutDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        
        // Then
        expectPut(dataSource, query, CoreError.DataSerialization())
    }
    
    func test_post_returns_no_response() {
        // Given
        let queryWithContentType = NetworkQuery(method: .post(type: .Json(entity: anyEntity())), path: anyString())
        let queryNoContentType = NetworkQuery(method: .post(type: nil), path: anyString())
        let url = anyURL()
        let decoder = DecoderSpy()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
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
        url: URL,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil
    ) -> PutNetworkDataSource<S> {
        let session = Utils.urlSession(request: request, response: response, jsonFileName: jsonFileName)
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
            _ expectedError: Error)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.put(nil, in: query).then { _ in
            print("")
        }.fail { error in
            if error.localizedDescription == expectedError.localizedDescription {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expectPutAllAlamofireError<S: Decodable>(
            value: [S],
            _ dataSource: PutNetworkDataSource<S>,
            _ query: Query,
            _ expectedError: Error)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.putAll(value, in: query).fail { error in
            if error.localizedDescription == expectedError.localizedDescription {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
