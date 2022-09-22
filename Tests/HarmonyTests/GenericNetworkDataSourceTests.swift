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
    
    func test() {
        let source = provideEmptyDataSource()
        source.getAll(NetworkQuery(method: .get, path: "")).then { entitites in
            
        }
    }
    
    private func provideEmptyDataSource() -> GetNetworkDataSource<MockEntity> {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockUrlProtocol.self]
        return GetNetworkDataSource<MockEntity>(url: "https://demo3068405.mockable.io/", session: Alamofire.Session(configuration: configuration))
    }
    
    private struct MockEntity: Decodable {
        
    }
}
