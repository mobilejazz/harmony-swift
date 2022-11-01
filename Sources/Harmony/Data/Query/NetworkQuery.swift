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
import Alamofire

/// A wrapper around a network query, to be used with the network data sources.
open class NetworkQuery: KeyQuery {
    
    /// The HTTP method
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
        
        /// Returns a copy of the HTTP method using the new content type. Throws if the method does not support a content type.
        /// - Parameter newContentType: the new content type to be used
        /// - Returns: a copy of the HTTP method using the new content type
        public func with(contentType newContentType: ContentType?) throws -> Self {
            if case .put = self {
                return .put(type: newContentType)
            } else if case .post = self {
                return .post(type: newContentType)
            } else {
                throw CoreError.NotValid()
            }
        }
        
        /// - Returns: the content type or nil if the method does not support it
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
    
    /// An abstraction of the content type and value in different forms
    public enum ContentType {
        case FormUrlEncoded(params: [String: String])
        case Json(entity: Encodable)
    }

    private let path: String
    private let params: [String: Any]
    private let headers: [String: String]
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
    
    private func mapToAlamofireMethod(method: Method) -> HTTPMethod {
        switch method {
        case .get:
            return .get
        case .delete:
            return .delete
        case .put:
            return .put
        case .post:
            return .post            
        }
    }

    public func request(url: URL, session: Session) -> DataRequest {
        let fullUrl = url.appendingPathExtension(path)
        let afMethod = mapToAlamofireMethod(method: method)
        var parameters: [String: Any] = self.params
        let encoding: URLEncoding = .default
        let headers = HTTPHeaders(self.headers)                
        
        if case let .put(type: contentType) = method {
            if let contentType {
                switch contentType {
                case .Json(entity: let entity):
                    let data = try! JSONEncoder().encode(entity)
                    if let dic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        parameters = dic
                    }
                case .FormUrlEncoded(params: let formURLEncodedParams):
                    parameters = formURLEncodedParams
                }
            }
        }
        
        return session.request(fullUrl,
                               method: afMethod,
                               parameters: parameters,
                               encoding: encoding,
                               headers: headers)
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
            method = try method.with(contentType: NetworkQuery.ContentType.Json(entity: value))
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
            method = try method.with(contentType: NetworkQuery.ContentType.Json(entity: value))
        }
        
        return self
    }
}
