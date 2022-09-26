//
// Created by Kerim Sari on 22.09.2022.
//

import Foundation
import Alamofire

class MockUrlProtocol: URLProtocol {

    public static var mockedRequest: URLRequest?
    public static var mockedResponse: URLResponse?
    public static var mockedData: Data?
    
    private weak var activeTask: URLSessionTask?

    override class public func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class public func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return true
    }

    private lazy var session: URLSession = {

        let configuration = URLSessionConfiguration.ephemeral
        configuration.headers = HTTPHeaders.default

        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    override class public func canonicalRequest(for request: URLRequest) -> URLRequest {
        
        guard let request = mockedRequest else { return getDefaultRequest(for: request) }
        
        return request
    }
    
    static private func getDefaultRequest(for request: URLRequest) -> URLRequest {
        guard let headers = request.allHTTPHeaderFields else { return request }

        do {
            return try URLEncoding.default.encode(request, with: headers)
        } catch {
            return request
        }
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

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let response = MockUrlProtocol.mockedResponse else {
            setDefaultResponse(task: task)
            return
        }
                
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
        
        guard let data = MockUrlProtocol.mockedData else {
            return
        }
        
        client?.urlProtocol(self, didLoad: data)
    }
    
    private func setDefaultResponse(task: URLSessionTask) {
        if let response = task.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        client?.urlProtocolDidFinishLoading(self)
    }
}

