//
// Copyright 2022 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

extension URL {
    func toURLRequest(query: NetworkQuery) throws -> URLRequest {
        let fullUrl = appendingPathComponent(query.path)
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
                components.queryItems = query.params.map { key, value in
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
