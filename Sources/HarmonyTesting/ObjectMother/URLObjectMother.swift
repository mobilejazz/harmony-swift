//
//  URLObjectMother.swift
//  Harmony
//
//  Created by Borja Arias Drake on 21.10.2022..
//

import Foundation

public func anyURL() -> URL {
    URL(string: "www.test.com")!
}

public func anyURLResponse(url: URL = anyURL(),
                           statusCode: Int = 200,
                           httpVersion: String = "HTTP/2.0",
                           headers: [String: String] = ["json": "application/json; charset=utf-8"]) -> URLResponse? {
    HTTPURLResponse(url: url,
                    statusCode: statusCode,
                    httpVersion: httpVersion,
                    headerFields: headers)
}

public func anyRequest(url: URL = anyURL(),
                       cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
                       timeout: TimeInterval = 1.0) -> URLRequest {
    URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
}
