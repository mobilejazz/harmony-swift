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

open class NetworkQuery: KeyQuery {

    public enum Method: Equatable {
        
        case get
        case delete
        case put(type: ContentType?)
        case post(type: ContentType?)

        public static func ==(lhs: NetworkQuery.Method, rhs: NetworkQuery.Method) -> Bool {
            switch (lhs, rhs) {
            case (.get, .get):
                return true
            case(.delete, .delete):
                return true
            case (.put, .put):
                return true
            case (.post, .post):
                return true
            default:
                return false
            }
        }
        
        public func with(contentType newContentType: ContentType?) -> Self {
            if case .put = self {
                return .put(type: newContentType)
            } else if case .post = self {
                return .post(type: newContentType)
            } else {
                return self
            }
        }
        
        public func contentType() -> NetworkQuery.ContentType? {
            switch self {
            case .get:
                return nil
            case .delete:
                return nil
            case .put(type: let type):
                return type
            case .post(type: let type):
                return type
            }
        }
    }

    public enum ContentType {
        case FormUrlEncoded(params: [String: String])
        case Json(entity: Encodable)
    }

    public let path: String
    public let params: [String: Any]
    public let headers: [String: String]
    public var method: Method
    public let key: String
    
    public init(method: Method, path: String, params: [String : Any] = [:], headers: [String: String] = [:], key: String? = nil) {
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers

        self.key = key ?? "\(path) ? \(params.map { key, value -> String in "\(key) = \(value)" }.joined(separator: "&"))"
    }
}

extension NetworkQuery {
    
    private func mapToUrlRequestMethod(method: Method) -> String {
        switch method {
        case .get:
            return "GET"
        case .delete:
            return "DELETE"
        case .put:
            return "PUT"
        case .post:
            return "POST"
        }
    }

//    public func request(url: URL, session: Session) -> DataRequest {
//        let fullUrl = url.appendingPathExtension(path)
//        let afMethod = mapToAlamofireMethod(method: method)
//        var parameters: [String: Any] = self.params
//        let encoding: URLEncoding = .default
//        let headers = HTTPHeaders(self.headers)
//
//        if case let .put(type: contentType) = method {
//            if let contentType {
//                switch contentType {
//                case .Json(entity: let entity):
//                    let data = try! JSONEncoder().encode(entity)
//                    if let dic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                        parameters = dic
//                    }
//                case .FormUrlEncoded(params: let formURLEncodedParams):
//                    parameters = formURLEncodedParams
//                }
//            }
//        }
//
//        return session.request(fullUrl,
//                               method: afMethod,
//                               parameters: parameters,
//                               encoding: encoding,
//                               headers: headers)
//    }
    
    public func request(url: URL) throws -> URLRequest {
        let fullUrl = url.appendingPathExtension(path)
        let finalUrl: URL
        let urlMethod = mapToUrlRequestMethod(method: method)

        // Calculate final URL based on method
        switch method {
        case .get, .delete:
            // Params go into the URL
            guard var components = URLComponents(url: fullUrl, resolvingAgainstBaseURL: false) else {
                throw CoreError.NotValid()
            }
            
            components.queryItems = params.map { (key, value) in
                URLQueryItem(name: key, value: value as? String)
            }
            
            guard let urlWithQueryItems = components.url else {
                throw CoreError.NotValid()
            }
            
            finalUrl = urlWithQueryItems
            
        case .put, .post:
            finalUrl = fullUrl
        }
        
        // Create the request with the final URL
        var request = URLRequest(url: finalUrl)
        
        // Add method to request
        request.httpMethod = urlMethod
        
        // Add headers to request
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add parameters to body depending on method
        switch method {
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
        
        return request
    }
}

extension NetworkQuery {
    func sanitizeContentType<T: Encodable>(value: T?) throws -> NetworkQuery {
        let contentType = method.contentType()
        
        if contentType != nil && value != nil {
            throw CoreError.IllegalArgument("Conflicting arguments to be used as request body")
        }
        
        // Updating query if value is passed as separated argument from the query
        if (contentType == nil && value != nil) {
            method = method.with(contentType: NetworkQuery.ContentType.Json(entity: value))
        }
        
        return self
    }
    
    func sanitizeArrayContentType<T: Encodable>(value: [T]) throws -> NetworkQuery {
        let contentType = method.contentType()
        
        if contentType != nil && !value.isEmpty {
            throw CoreError.IllegalArgument("Conflicting arguments to be used as request body")
        }
        
        // Updating query if value is passed as separated argument from the query
        if (contentType == nil && !value.isEmpty) {
            method = method.with(contentType: NetworkQuery.ContentType.Json(entity: value))
        }
        
        return self
    }
}
