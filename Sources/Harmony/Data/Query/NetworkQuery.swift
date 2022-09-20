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

    public enum Method {
        case get
        case delete
        case content(type: ContentType<Any>)
        case post(type: ContentType<Any>)
        case put(type: ContentType<Any>)
    }

    public enum ContentType<T> {
        case FormUrlEncoded(params: [String:String])
        case Json(entity: T)
    }

    private let path: String
    private let method: Method
    private let params: [String: Any]
    private let headers: [String: String]

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
    
    private func get(method: Method) -> HTTPMethod {
        switch method {
        case .get:
            return .get
        case .delete:
            return .delete
        case .post(type: .FormUrlEncoded(params: [:])):
            return .post
        default:
            return .get
        }
    }

    
    open func request(url: String) -> DataRequest {
        
        let path = "\(url)\(self.path)"
        let method = get(method: self.method)
        let parameters = self.params
        let encoding = URLEncoding.default
        let headers = HTTPHeaders(self.headers)

        return AF.request(path, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
   
}
