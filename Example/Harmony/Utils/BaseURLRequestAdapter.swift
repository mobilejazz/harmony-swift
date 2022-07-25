//
// Copyright 2017 Mobile Jazz SL
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

public class BaseURLRequestAdapter: RequestAdapter {
    
    // Example of usage of a bearer token
    public let baseURL : URL
    
    public init(_ baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let incomingURL = urlRequest.url else {
            return urlRequest
        }
        
        if incomingURL.scheme != nil {
            return urlRequest
        }
        
        var request = urlRequest
        
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = "\(baseURL.path)\(incomingURL.path)"
        
        if let query = incomingURL.query {
            components.query = query
        }
        
        request.url = components.url
        
        return request
    }
}
