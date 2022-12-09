//
//  GenericNetworkDataSourceUtils.swift
//  HarmonyTests
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation

@available(iOS 13.0, *)
final class GenericDataSourceUtils {

    static func urlSession(request: URLRequest?, response: URLResponse?, jsonFileName: String?) -> URLSession {
        let configuration = URLSessionConfiguration.default

        MockUrlProtocol.mockedRequest = request
        MockUrlProtocol.mockedResponse = response
        MockUrlProtocol.mockedData = provideData(from: jsonFileName, with: "json")
        
        configuration.protocolClasses = [MockUrlProtocol.self]
        return URLSession(configuration: configuration)
    }


    static func provideData(from file: String?, with extension: String) -> Data? {
        guard let file = file else { return nil }
        
        guard let filePath = Bundle(for: GenericDataSourceUtils.self).path(forResource: file, ofType: `extension`) else {
            return nil
        }
        
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
}

