//
//  GenericNetworkDataSourceUtils.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation
import Alamofire

@available(iOS 13.0, *)
final class GenericDataSourceUtils {

    static func provideMockAlamofireSession(request: URLRequest?, response: URLResponse?, jsonFileName: String?) -> Session {
        let configuration = URLSessionConfiguration.af.default

        MockUrlProtocol.mockedRequest = request
        MockUrlProtocol.mockedResponse = response

        MockUrlProtocol.mockedData = provideData(from: jsonFileName, with: "json")

        configuration.protocolClasses = [MockUrlProtocol.self]
        return Alamofire.Session(configuration: configuration)
    }


    static func provideData(from file: String?, with extension: String) -> Data? {
        guard let file = file else { return nil }
        
        guard let filePath = Bundle(for: GenericDataSourceUtils.self).path(forResource: file, ofType: `extension`) else {
            return nil
        }
        
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
}

