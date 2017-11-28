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

public enum MJSwiftCoreAlamofireError : Error {
    case jsonSerialization
}

public let AlamofireFutureHTTPStatusCodeErrorDomain = "com.mobilejazz.alamofire.future.statusCode"
public let AlamofireFutureErrorDomain = "com.mobilejazz.alamofire.future"
public let AlamofireFutureJSONMappingErrorCode = 1001

public extension DataRequest {
    
    public func toFuture() -> Future<[String:AnyObject]> {
        return self.then(success: { json in json })
    }
    
    public func then<T>(queue: DispatchQueue? = nil,
                        options: JSONSerialization.ReadingOptions = .allowFragments,
                        completion: @escaping ([String : AnyObject]) -> Future<T>) -> Future<T> {
        let future: Future<T> = Future()
        response(queue: queue,
                 responseSerializer: DataRequest.jsonResponseSerializer(options: options),
                 completionHandler: { response in
                    switch response.result {
                    case .failure(let error):
                        future.set(error)
                    case .success(let data):
                        if let json = data as? [String : AnyObject] {
                            future.set(completion(json))
                        } else {
                            future.set(MJSwiftCoreAlamofireError.jsonSerialization)
                        }
                    }
        })
        return future
    }
    
    public func then<T>(queue: DispatchQueue? = nil,
                        options: JSONSerialization.ReadingOptions = .allowFragments,
                        success: @escaping ([String : AnyObject]) -> T?,
                        failure: @escaping (_ error: Error, _ response: HTTPURLResponse?) -> Error = { (error, _) in error }) -> Future<T> {
        let future = Future<T>()
        response(queue: queue,
                 responseSerializer: DataRequest.jsonResponseSerializer(options: options),
                 completionHandler: { response in
                    switch response.result {
                    case .failure(let error):
                        future.set(failure(error, response.response))
                    case .success(let data):
                        if let json = data as? [String : AnyObject] {
                            future.set(success(json))
                        } else {
                            future.set(MJSwiftCoreAlamofireError.jsonSerialization)
                        }
                    }
        })
        return future
    }
}
