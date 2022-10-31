//
//  GenericNetworkDataSourceTests.swift
//  HarmonyTesting-iOS
//
//  Created by Kerim Sari on 22.09.2022.
//

import Foundation
import Harmony
import Nimble
import XCTest
import HarmonyTesting

enum Function {
    case get
    case getAll
    case put
    case putAll
    case delete
    case deleteAll
}

@available(iOS 13.0, *)
class GetNetworkDataSourceTests: XCTestCase {

    private typealias Utils = GenericDataSourceUtils
    
    func test_getAll_allobjects_query_not_supported() {
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: anyURL())
        let query = AllObjectsQuery()
        
        expectGetError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_getAll_networkquery_method_delete_not_supported() {
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: anyURL())
        let query = NetworkQuery(method: .delete, path: "")
        
        expectGetError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_getAll_networkquery_method_put_not_supported() {
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: anyURL())
        let query = NetworkQuery(method: .put(type: NetworkQuery.ContentType.FormUrlEncoded(params: [:])), path: "")
        
        expectGetError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_get_response_statuscode_validation_failure() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let statusCode = 400
        let response = anyURLResponse(statusCode: statusCode)
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: anyString())

        expectGetAlamofireError(dataSource, query, CoreError.Failed("HTTP status code: 400"))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_failure() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let decoder = DecoderSpy()
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: anyString())
                               
        expectGetError(dataSource, query, CoreError.DataSerialization(), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_getAll_no_data_decoding_failure() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let decoder = DecoderSpy()
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: anyString())
                               
        expectGetError(dataSource, query, CoreError.DataSerialization(), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_success() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: anyString())
                               
        expectGetError(dataSource, query, nil, .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_failure() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: anyString())
                               
        expectGetError(dataSource, query, CoreError.DataSerialization(), .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_success() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: anyString())
                               
        expectGetError(dataSource, query, nil, .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_no_data_decoding_failure() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<CodableEntity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: anyString())
                               
        expectGetError(dataSource, query, CoreError.DataSerialization(), .get)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_get_incompatible_entity_type_decoding_failure() {
        let url = anyURL()
        let request = anyRequest(url: url)
        let response = anyURLResponse(statusCode: 200)        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Int> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: anyString())
                               
        expectGetError(dataSource, query, CoreError.DataSerialization(), .get)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
        
    private func expectGetAll<S: Decodable>(_ dataSource: GetNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")
        
        dataSource.getAll(query)
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

    private func expectGet<S: Decodable>(_ dataSource: GetNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")
        
        dataSource.get(query)
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

    private func expectGetError<S: Decodable>(
        _ dataSource: GetNetworkDataSource<S>,
        _ query: Query,
        _ expectedError: Error?,
        _ function: Function)
    {
        if function == .getAll {
            expectGetAll(dataSource, query, expectedError)
        } else {
            expectGet(dataSource, query, expectedError)
        }
    }

    private func expectGetAlamofireError<S: Decodable>(
        _ dataSource: GetNetworkDataSource<S>,
        _ query: Query,
        _ expectedError: Error)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.getAll(query).then { _ in }.fail { error in
            if error.localizedDescription == expectedError.localizedDescription {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    private func provideGetDataSource<S: Decodable>(
        url: URL,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil) -> GetNetworkDataSource<S>
    {        
        let session = Utils.urlSession(request: request, response: response, jsonFileName: jsonFileName)
        return GetNetworkDataSource<S>(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }
}
