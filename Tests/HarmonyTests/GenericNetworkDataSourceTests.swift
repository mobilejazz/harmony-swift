//
//  GenericNetworkDataSourceTests.swift
//  HarmonyTesting-iOS
//
//  Created by Kerim Sari on 22.09.2022.
//

import Foundation
import XCTest
import Nimble
import Harmony
import Alamofire

@available(iOS 13.0, *)
class GenericNetworkDataSourceTests: XCTestCase {
    
    private struct MockEntity: Decodable, Equatable {}
    
    func test_query_not_supported() {
        let dataSource = provideDataSource(url: "")
        let query = AllObjectsQuery()
        
        expectError(dataSource, query, CoreError.QueryNotSupported())
    }
    
    func test_query_method_not_supported() {
        let dataSource = provideDataSource(url: "")
        let query = NetworkQuery(method: .delete, path: "")
        
        expectError(dataSource, query, CoreError.QueryNotSupported())
    }
    
    func test_response_validation_failure() {
        let url = "dummy"
        let statusCode = 400
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json" : "application/json; charset=utf-8"])
        
        let dataSource = provideDataSource(url: url, request: request, response: response)
        let query = NetworkQuery(method: .get, path: url)

        expectAFError(dataSource, query, AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
    }
    
    func test_response_url_validation_failure() {
        let url = String()
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: 200, httpVersion: "HTTP/2.0", headers: ["json" : "application/json; charset=utf-8"])
        
        let dataSource = provideDataSource(url: url, request: request, response: response)
        let query = NetworkQuery(method: .get, path: url)

        expectAFError(dataSource, query, AFError.invalidURL(url: url))        
    }
    
    func test_decoding_failure() {
        let url = "www.google.com"
        let statusCode = 200
        
        let request = provideRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeout: 1.0)
        let response = provideResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/2.0", headers: ["json" : "application/json; charset=utf-8"])
        
        let decoder = DecoderSpy()
        
        let dataSource = provideDataSource(url: url, request: request, response: response, decoder: decoder, jsonFileName: "Entity")
        let query = NetworkQuery(method: .get, path: url)
                               
        expectError(dataSource, query,  DecodingError.typeMismatch(Array<Any>.self, DecodingError.Context.init(codingPath: [], debugDescription: "")))
        
        expect{decoder.decodeCalledCount}.to(equal(1))
    }
    
    private func provideRequest(url: String, cachePolicy: URLRequest.CachePolicy, timeout: TimeInterval) -> URLRequest {
        
        return URLRequest(url: URL(fileURLWithPath: url), cachePolicy: cachePolicy,timeoutInterval: timeout)
    }
    
    private func provideResponse(url: String, statusCode: Int, httpVersion: String, headers: [String: String]) -> URLResponse? {
        
        return HTTPURLResponse(url: URL(fileURLWithPath: url), statusCode: statusCode,
            httpVersion: httpVersion, headerFields: headers)
    }

    private func expectAFError(
            _ dataSource: GetNetworkDataSource<Entity>,
            _ query: Query,
            _ expectedError: AFError) {

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
        
    private func expectError(
        _ dataSource: GetNetworkDataSource<Entity>,
        _ query: Query,
        _ expectedError: Error) {
            
        let expectation = XCTestExpectation(description: "expectation")
            
        dataSource.getAll(query).then { _ in }.fail { error in
            if type(of: error) == type(of: expectedError) {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    fileprivate func provideData(from file: String?, with extension: String) -> Data? {
        
        guard let filePath = Bundle(for: type(of: self)).path(forResource: file, ofType: `extension`) else {
            return nil
        }
        
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
    
    private func provideDataSource(
        url: String,
        request: URLRequest? = nil,
        response: URLResponse? = nil,
        decoder: JSONDecoder? = nil,
        jsonFileName: String? = nil) -> GetNetworkDataSource<Entity> {
        
        let configuration = URLSessionConfiguration.af.default
        
        MockUrlProtocol.mockedRequest = request
        MockUrlProtocol.mockedResponse = response
        
        MockUrlProtocol.mockedData = provideData(from: jsonFileName, with: "json")
        
        configuration.protocolClasses = [MockUrlProtocol.self]
        let session = Alamofire.Session(configuration: configuration)
            
        return GetNetworkDataSource<Entity>(url: url, session: session, decoder: decoder ?? DecoderSpy())
    }        
}
