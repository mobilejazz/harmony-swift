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

@available(iOS 13.0, *)
class GenericNetworkDataSourceTests: XCTestCase {
    private enum Function {
        case get
        case getAll
    }
    
    func test_allobjects_query_not_supported() {
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: "")
        let query = AllObjectsQuery()
        
        expectError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_networkquery_method_delete_not_supported() {
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: "")
        let query = NetworkQuery(method: .delete, path: "")
        
        expectError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_networkquery_method_put_not_supported() {
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: "")
        let query = NetworkQuery(method: .put(type: NetworkQuery.ContentType<String>.FormUrlEncoded(params: [:])), path: "")
        
        expectError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_networkquery_method_post_not_supported() {
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: "")
        let query = NetworkQuery(method: .post(type: NetworkQuery.ContentType<String>.FormUrlEncoded(params: [:])), path: "")
        
        expectError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_response_statuscode_validation_failure() {
        let url = "dummy"
        let statusCode = 400
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)

        expectAFError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_response_empty_url_validation_failure() {
        let url = String()
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)

        expectAFError(dataSource, query, AFError.invalidURL(url: url))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query, DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: [], debugDescription: "")), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_getAll_no_data_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query, CoreError.DecodingFailed(), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_success() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query, nil, .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query, DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: [], debugDescription: "")), .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_success() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query, nil, .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_no_data_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query, CoreError.DecodingFailed(), .get)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_get_incompatible_entity_type_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Int> = provideDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query, CoreError.DecodingFailed(), .get)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    private func provideRequest(url: String, cachePolicy: URLRequest.CachePolicy, timeout: TimeInterval) -> URLRequest {
        return URLRequest(url: URL(fileURLWithPath: url), cachePolicy: cachePolicy, timeoutInterval: timeout)
    }
    
    private func provideResponse(url: String, statusCode: Int, httpVersion: String, headers: [String: String]) -> URLResponse? {
        return HTTPURLResponse(url: URL(fileURLWithPath: url), statusCode: statusCode,
                               httpVersion: httpVersion, headerFields: headers)
    }
    
    fileprivate func expectGetAll<S: Decodable>(_ dataSource: GetNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
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
    
    fileprivate func expectGet<S: Decodable>(_ dataSource: GetNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
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
    
    private func expectError<S: Decodable>(
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

    private func expectAFError(
        _ dataSource: GetNetworkDataSource<Entity>,
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
    
    fileprivate func provideData(from file: String?, with extension: String) -> Data? {
        guard let file = file else { return nil }
        
        guard let filePath = Bundle(for: type(of: self)).path(forResource: file, ofType: `extension`) else {
            return nil
        }
        
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
    
    private func provideDataSource<S: Decodable>(
        url: String,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil) -> GetNetworkDataSource<S>
    {
        let configuration = URLSessionConfiguration.af.default
        
        MockUrlProtocol.mockedRequest = request
        MockUrlProtocol.mockedResponse = response
        
        MockUrlProtocol.mockedData = provideData(from: jsonFileName, with: "json")
        
        configuration.protocolClasses = [MockUrlProtocol.self]
        let session = Alamofire.Session(configuration: configuration)
            
        return GetNetworkDataSource<S>(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }
}