//
// Copyright 2019 Mobile Jazz SL
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
import Harmony
import Alamofire

///
/// Logs CURLS of incoming requests
///
public class URLLoggerRequestAdapter: RequestAdapter {
    private let logger: Logger
    private let tag: String?
    
    public init(_ logger: Logger, tag: String? = nil) {
        self.logger = logger
        self.tag = tag
    }
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        let curl = urlRequest.curl(pretty: true)
        logger.info(tag: tag, "\(curl)")
        return urlRequest
    }
}

private extension URLRequest {
    func curl(pretty: Bool = false) -> String {
        var data: String = ""
        let complement = pretty ? "\\\n" : ""
        let method = "-X \(httpMethod ?? "GET") \(complement)"
        let url = "\"" + (self.url?.absoluteString ?? "") + "\""
        
        var header = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key, value) in httpHeaders {
                header += "-H \"\(key): \(value)\" \(complement)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            data = "-d \"\(bodyString)\" \(complement)"
        }
        
        let command = "curl -i " + complement + method + header + data + url
        
        return command
    }
}

