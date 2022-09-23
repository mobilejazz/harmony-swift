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

class GenericNetworkDataSourceTests: XCTestCase {
            
    private let baseUrl = "https://www.google.com/"
    private let path = "doodles"
    
    //private let baseUrl = "https://demo3068405.mockable.io/"
    //private let path = "items"
    
    private struct MockEntity: Decodable, Equatable {}
    
    func test_query_not_supported() {
        let dataSource = provideEmptyDataSource(url: baseUrl)
        let query = AllObjectsQuery()
        
        let expectation = XCTestExpectation(description: "All Objects Query")
        
        expectError(dataSource, query, expectation, CoreError.QueryNotSupported())
    }
    
    func test_query_method_not_supported() {
        let dataSource = provideEmptyDataSource(url: baseUrl)
        let query = NetworkQuery(method: .delete, path: self.path)
        
        let expectation = XCTestExpectation(description: "Method Not Supported")
        
        expectError(dataSource, query, expectation, CoreError.QueryNotSupported())
    }
    
    func test_decoding_error() {
        let dataSource = provideEmptyDataSource(url: "www.")
        let query = NetworkQuery(method: .get, path: self.path)
        
        let expectation = XCTestExpectation(description: "Decoding Failed")
        
        expectError(dataSource, query, expectation, CoreError.DecodingFailed())
    }
    
    func test_success() {
        let dataSource = provideEmptyDataSource(url: baseUrl)
        let query = NetworkQuery(method: .get, path: self.path)
        
        let expectation = XCTestExpectation(description: "Success")
        
        dataSource.getAll(query).then { entities in
            let result = entities
            expectation.fulfill()
        }.fail { error in
            let err = error
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
        
    private func expectError(
        _ dataSource: GetNetworkDataSource<GenericNetworkDataSourceTests.MockEntity>,
        _ query: Query,
        _ expectation: XCTestExpectation,
        _ expectedError: ClassError) {
            
        dataSource.getAll(query).then { _ in }.fail { error in
            if type(of: error) == type(of: expectedError) {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func provideEmptyDataSource(url: String) -> GetNetworkDataSource<MockEntity> {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockUrlProtocol.self]
        
        return GetNetworkDataSource<MockEntity>(
            url: url, session: Alamofire.Session(configuration: configuration))
    }
    
    
}
