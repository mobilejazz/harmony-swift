//
//  URL+URLRequest.swift
//  Harmony
//
//  Created by Borja Arias Drake on 31.10.2022..
//

import Foundation

extension URL {

    func toURLRequest(query: NetworkQuery) throws -> URLRequest {
        let fullUrl = self.appendingPathComponent(query.path)
        let finalUrl = try modifiedURLForMethod(from: fullUrl, query: query)
        var request = URLRequest(url: finalUrl)
        request.httpMethod = query.method.toUrlRequestMethod()
        addHeaders(to: &request, query: query)
        try addBody(to: &request, query: query)
        return request
    }
    
    private func modifiedURLForMethod(from url: URL, query: NetworkQuery) throws -> URL {
        switch query.method {
        case .get, .delete:
            // Params go into the URL
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw CoreError.NotValid()
            }
            
            if !query.params.isEmpty {
                components.queryItems = query.params.map { (key, value) in
                    URLQueryItem(name: key, value: value as? String)
                }
            }
            guard let urlWithQueryItems = components.url else {
                throw CoreError.NotValid()
            }
            
            return urlWithQueryItems
            
        case .put, .post:
            return url
        }
    }
    
    private func addBody(to request: inout URLRequest, query: NetworkQuery) throws {
        switch query.method {
        case .put(type: let contentType), .post(type: let contentType):
            if let contentType {
                let paramsData: Data
                switch contentType {
                case .Json(entity: let entity):
                    paramsData = try JSONEncoder().encode(entity)
                case .FormUrlEncoded(params: let formURLEncodedParams):
                    paramsData = try JSONSerialization.data(withJSONObject: formURLEncodedParams)
                }
                request.httpBody = paramsData
            }
        default: break
        }
    }
    
    private func addHeaders(to request: inout URLRequest, query: NetworkQuery) {
        for (key, value) in query.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
    }
}
