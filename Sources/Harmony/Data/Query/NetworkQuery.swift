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

    public func request(url: String, session: Session) -> DataRequest {
        let path = "\(url)\(self.path)"
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
        
        return session.request(path,
                               method: afMethod,
                               parameters: parameters,
                               encoding: encoding,
                               headers: headers)
    }
}
