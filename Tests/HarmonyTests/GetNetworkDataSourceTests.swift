//
//  GenericNetworkDataSourceTests.swift
//  HarmonyTesting-iOS
//
//  Created by Kerim Sari on 22.09.2022.
//

import Alamofire
import Foundation
import Harmony
import Nimble
import XCTest

enum Function {
    case get
    case getAll
    case put
    case putAll
    case delete
    case deleteAll
}

@available(iOS 13.0, *)
class GenericNetworkDataSourceTests: XCTestCase {

    private typealias Utils = GenericDataSourceUtils
    
    // MARK: Get
    
    func test_getAll_allobjects_query_not_supported() {
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: "")
        let query = AllObjectsQuery()
        
        expectGetError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_getAll_networkquery_method_delete_not_supported() {
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: "")
        let query = NetworkQuery(method: .delete, path: "")
        
        expectGetError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_getAll_networkquery_method_put_not_supported() {
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: "")
        let query = NetworkQuery(method: .put(type: NetworkQuery.ContentType.FormUrlEncoded(params: [:])), path: "")
        
        expectGetError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_get_response_statuscode_validation_failure() {
        let url = "dummy"
        let statusCode = 400
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)

        expectGetAlamofireError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_get_response_empty_url_validation_failure() {
        let url = String()
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)

        expectGetAlamofireError(dataSource, query, AFError.invalidURL(url: url))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: [], debugDescription: "")), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_getAll_no_data_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, CoreError.DataSerialization(), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_success() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, nil, .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: [], debugDescription: "")), .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_success() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, nil, .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_no_data_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, CoreError.DataSerialization(), .get)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_get_incompatible_entity_type_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = Utils.provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = Utils.provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Int> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
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
        _ expectedError: AFError)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.getAll(query).then { _ in }.fail { error in
            if let error = error as? AFError {
                if error.localizedDescription == expectedError.localizedDescription {
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    private func provideGetDataSource<S: Decodable>(
        url: String,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil) -> GetNetworkDataSource<S>
    {
        let session = Utils.provideMockAlamofireSession(request: request, response: response, jsonFileName: jsonFileName)
        return GetNetworkDataSource<S>(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }
}
