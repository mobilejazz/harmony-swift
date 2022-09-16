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

class NetworkQuery: Query {
        
    private let path: String
    private let method: String
    private let params: [String: Any]
    private let headers: [String: String]
    private let key: String?
    
    init(method: String, path: String, params: [String : Any] = [:], headers: [String: String] = [:], key: String) {
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.key = key
    }
    
    private func getMethod(name: String) -> HTTPMethod {
        switch name {
        case "GET":
            return .get
        case "POST":
            return .post
        case "DELETE":
            return .delete
        default:
            return .get
        }
    }
}

extension NetworkQuery {
    
    func buildRequest() -> DataRequest {
        
        let path = self.path
        let method = getMethod(name: self.method)
        let parameters = self.params
        let encoding = URLEncoding.default
        let headers = HTTPHeaders(self.headers)

        return AF.request(path, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
   
}
