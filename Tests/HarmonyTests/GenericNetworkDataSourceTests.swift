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
        case put
        case putAll
        case delete
        case deleteAll
    }
    
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
        let query = NetworkQuery(method: .put(type: NetworkQuery.ContentType<String>.FormUrlEncoded(params: [:])), path: "")
        
        expectGetError(dataSource, query, CoreError.QueryNotSupported(), .getAll)
    }
    
    func test_get_response_statuscode_validation_failure() {
        let url = "dummy"
        let statusCode = 400
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)

        expectGetAlamofireError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_get_response_empty_url_validation_failure() {
        let url = String()
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)

        expectGetAlamofireError(dataSource, query, AFError.invalidURL(url: url))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: [], debugDescription: "")), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_getAll_no_data_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, CoreError.DecodingFailed(), .getAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_getAll_decoding_success() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, nil, .getAll)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "EntityList")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: [], debugDescription: "")), .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_decoding_success() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, nil, .get)
        expect { decoder.decodeCalledCount }.to(equal(1))
    }
    
    func test_get_no_data_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Entity> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, CoreError.DecodingFailed(), .get)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_get_incompatible_entity_type_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: GetNetworkDataSource<Int> = provideGetDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .get, path: url)
                               
        expectGetError(dataSource, query, CoreError.DecodingFailed(), .get)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_deleteAll_allobjects_query_not_supported() {
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: "")
        let query = AllObjectsQuery()
        
        expectDeleteError(dataSource, query, CoreError.QueryNotSupported(), .deleteAll)
    }
    
    func test_deleteAll_networkquery_method_get_not_supported() {
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: "")
        let query = NetworkQuery(method: .get, path: "")
        
        expectDeleteError(dataSource, query, CoreError.QueryNotSupported(), .deleteAll)
    }
    
    func test_deleteAll_networkquery_method_put_not_supported() {
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: "")
        let query = NetworkQuery(method: .put(type: NetworkQuery.ContentType<String>.FormUrlEncoded(params: [:])), path: "")
        
        expectDeleteError(dataSource, query, CoreError.QueryNotSupported(), .deleteAll)
    }
    
    func test_delete_response_statuscode_validation_failure() {
        let url = "dummy"
        let statusCode = 400
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .delete, path: url)

        expectDeleteAlamofireError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_delete_response_empty_url_validation_failure() {
        let url = String()
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .delete, path: url)

        expectDeleteAlamofireError(dataSource, query, AFError.invalidURL(url: url))
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_deleteAll_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .delete, path: url)
                               
        expectDeleteError(dataSource, query, nil, .deleteAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
    
    func test_deleteAll_no_data_decoding_failure() {
        let url = "www.dummy.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json": "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource: DeleteNetworkDataSource = provideDeleteDataSource(url: url, request: request, response: response, decoder: decoder)
        let query = NetworkQuery(method: .delete, path: url)
                               
        expectDeleteError(dataSource, query, CoreError.DecodingFailed(), .deleteAll)
        expect { decoder.decodeCalledCount }.to(equal(0))
    }
        
    func test_putAll_allobjects_query_not_supported() {
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: "")
        let query = AllObjectsQuery()
        
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .putAll)
    }
    
    func test_putAll_networkquery_method_delete_not_supported() {
        let dataSource: PutNetworkDataSource<Entity> = providePutDataSource(url: "")
        let query = NetworkQuery(method: .delete, path: "")
        
        expectPutError(dataSource, query, CoreError.QueryNotSupported(), .putAll)
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

    fileprivate func expectPutAll<S: Decodable>(_ dataSource: PutNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.putAll([], in: query)
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

    fileprivate func expectPut<S: Decodable>(_ dataSource: PutNetworkDataSource<S>, _ query: Query, _ expectedError: Error?) {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.put(nil, in: query)
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

    fileprivate func expectDelete(_ dataSource: DeleteNetworkDataSource, _ query: Query, _ expectedError: Error?) {
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

    private func expectPutError<S: Decodable>(
            _ dataSource: PutNetworkDataSource<S>,
            _ query: Query,
            _ expectedError: Error?,
            _ function: Function)
    {
        if function == .putAll {
            expectPutAll(dataSource, query, expectedError)
        } else {
            expectPut(dataSource, query, expectedError)
        }
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

    private func expectPutAlamofireError<S: Decodable>(
            _ dataSource: PutNetworkDataSource<S>,
            _ query: Query,
            _ expectedError: AFError)
    {
        let expectation = XCTestExpectation(description: "expectation")

        dataSource.putAll([], in: query).then { _ in }.fail { error in
                    if let error = error as? AFError {
                        if error.localizedDescription == expectedError.localizedDescription {
                            expectation.fulfill()
                        }
                    }
                }

        wait(for: [expectation], timeout: 1.0)
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
    
    fileprivate func provideData(from file: String?, with extension: String) -> Data? {
        guard let file = file else { return nil }
        
        guard let filePath = Bundle(for: type(of: self)).path(forResource: file, ofType: `extension`) else {
            return nil
        }
        
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
    
    private func providePutDataSource<S: Decodable>(
        url: String,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil
    ) -> PutNetworkDataSource<S> {
        let session = provideMockAlamofireSession(request: request, response: response, jsonFileName: jsonFileName)
        return PutNetworkDataSource<S>(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }

    private func provideGetDataSource<S: Decodable>(
        url: String,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil) -> GetNetworkDataSource<S>
    {
        let session = provideMockAlamofireSession(request: request, response: response, jsonFileName: jsonFileName)
        return GetNetworkDataSource<S>(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }

    private func provideDeleteDataSource(
            url: String,
            request: URLRequest? = nil,
            response: URLResponse? = nil,
            decoder: JSONDecoder? = nil,
            jsonFileName: String? = nil) -> DeleteNetworkDataSource
    {
        let session = provideMockAlamofireSession(request: request, response: response, jsonFileName: jsonFileName)
        return DeleteNetworkDataSource(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }

    private func provideMockAlamofireSession(request: URLRequest?, response: URLResponse?, jsonFileName: String?) -> Session {
        let configuration = URLSessionConfiguration.af.default

        MockUrlProtocol.mockedRequest = request
        MockUrlProtocol.mockedResponse = response

        MockUrlProtocol.mockedData = provideData(from: jsonFileName, with: "json")

        configuration.protocolClasses = [MockUrlProtocol.self]
        return Alamofire.Session(configuration: configuration)
    }
}
