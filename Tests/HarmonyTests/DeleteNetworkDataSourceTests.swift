//
//  DeleteNetworkDataSourceTests.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Alamofire
import Foundation
import Harmony
import Nimble
import XCTest
import HarmonyTesting

@available(iOS 13.0, *)
final class DeleteNetworkDataSourceTests: XCTestCase {

    private typealias Utils = GenericDataSourceUtils
    
    func test_deleteAll_allobjects_query_not_supported() {
        // Given
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: anyURL())
        let query = AllObjectsQuery()
        
        // Then
        expectDeleteError(dataSource, query, CoreError.QueryNotSupported(), .deleteAll)
    }
    
    func test_deleteAll_networkquery_method_get_not_supported() {
        // Given
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: anyURL())
        let query = NetworkQuery(method: .get, path: "")
        
        // Then
        expectDeleteError(dataSource, query, CoreError.QueryNotSupported(), .deleteAll)
    }
    
    func test_deleteAll_networkquery_method_put_not_supported() {
        // Given
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: anyURL())
        let query = NetworkQuery(method: .put(type: NetworkQuery.ContentType.FormUrlEncoded(params: [:])), path: "")
        
        expectDeleteError(dataSource, query, CoreError.QueryNotSupported(), .deleteAll)
    }
    
    func test_delete_response_statuscode_validation_failure() {
        // Given
        let url = anyURL()
        let statusCode = 400
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: statusCode)
        let decoder = DecoderSpy()
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .delete, path: anyString())

        // Then
        expectDeleteAlamofireError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_deleteAll_decoding_failure() {
        // Given
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let decoder = DecoderSpy()
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .delete, path: anyString())
                               
        // Then
        expectDeleteError(dataSource, query, nil, .deleteAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_deleteAll_no_data_decoding_failure() {
        // Given
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let decoder = DecoderSpy()
        
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .delete, path: anyString())

        // Then
        expectDeleteError(dataSource, query, CoreError.DataSerialization(), .deleteAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }

    fileprivate func expectDeleteAll(_ dataSource: DeleteNetworkDataSource, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.deleteAll(query)
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
    
    private func expectDelete(_ dataSource: DeleteNetworkDataSource, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.delete(query)
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
    
    private func expectDeleteError(
            _ dataSource: DeleteNetworkDataSource,
            _ query: Query,
            _ expectedError: Error?,
            _ function: Function)
    {
        if function == .deleteAll {
            expectDeleteAll(dataSource, query, expectedError)
        } else {
            expectDelete(dataSource, query, expectedError)
        }
    }
    
    private func provideDeleteDataSource(
            url: URL,
            request: URLRequest? = nil,
            response: URLResponse? = nil,
            decoder: JSONDecoder? = nil,
            jsonFileName: String? = nil) -> DeleteNetworkDataSource
    {
        let session = Utils.provideMockAlamofireSession(request: request, response: response, jsonFileName: jsonFileName)
        return DeleteNetworkDataSource(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }
    
    private func expectDeleteAlamofireError(
            _ dataSource: DeleteNetworkDataSource,
            _ query: Query,
            _ expectedError: AFError)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.deleteAll(query).then { _ in }.fail { error in
                    if let error = error as? AFError {
                        if error.localizedDescription == expectedError.localizedDescription {
                            expectation.fulfill()
                        }
                    }
                }

        wait(for: [expectation], timeout: 1.0)
    }
}
