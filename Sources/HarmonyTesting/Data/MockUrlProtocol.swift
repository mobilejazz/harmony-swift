//
// Created by Kerim Sari on 22.09.2022.
//

import Foundation
import Harmony

class MockUrlProtocol: URLProtocol {
    public static var mockedRequest: URLRequest?
    public static var mockedResponse: URLResponse?
    public static var mockedData: Data?

    private weak var activeTask: URLSessionTask?

    override public class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override public class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return true
    }

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral

        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        guard let request = mockedRequest else { return getDefaultRequest(for: request) }

        return request
    }

    private static func getDefaultRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        guard let request = MockUrlProtocol.mockedRequest else {
            activeTask = session.dataTask(with: request)
            return
        }

        activeTask = session.dataTask(with: request)
        activeTask?.resume()
    }

    override public func stopLoading() {
        activeTask?.cancel()
    }
}

extension MockUrlProtocol: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let response = MockUrlProtocol.mockedResponse else {
            setDefaultResponse(task: task)
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = MockUrlProtocol.mockedData {
            client?.urlProtocol(self, didLoad: data)
        } else {
            client?.urlProtocol(self, didFailWithError: error ?? CoreError.Failed())
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    private func setDefaultResponse(task: URLSessionTask) {
        if let response = task.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        client?.urlProtocolDidFinishLoading(self)
    }
}
