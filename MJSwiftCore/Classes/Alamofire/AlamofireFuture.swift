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
                    case .failure://(let error):
                        let finalError = NSError(domain:AlamofireFutureHTTPStatusCodeErrorDomain, code:(response.response?.statusCode)!, userInfo:nil)
                        future.set(finalError)
                    case .success(let data):
                        if let json = data as? [String : AnyObject] {
                            future.set(completion(json))
                        } else {
                            future.set(NSError(domain:AlamofireFutureErrorDomain, code:AlamofireFutureJSONMappingErrorCode, userInfo: nil))
                        }
                    }
        })
        
        return future
    }
    
    public func then<T>(queue: DispatchQueue? = nil,
                        options: JSONSerialization.ReadingOptions = .allowFragments,
                        success: @escaping ([String : AnyObject]) -> T?,
                        failure: @escaping (_ error: Error, _ response: HTTPURLResponse?) -> NSError = { (error, response) in return NSError(domain:AlamofireFutureHTTPStatusCodeErrorDomain, code:(response?.statusCode)!, userInfo:nil)}) -> Future<T> {
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
                            future.set(NSError(domain:AlamofireFutureErrorDomain, code:AlamofireFutureJSONMappingErrorCode, userInfo: nil))
                        }
                    }
        })
        return future
    }
}


public extension Dictionary where Key == String, Value == AnyObject {
    public func decodeAs<T>(_ type : T.Type) throws -> T where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let object = try JSONDecoder().decode(type, from: data)
        return object
    }
    
    public func decodeAs<T>(_ type : T.Type) -> Future<T> where T : Decodable {
        do {
            let object : T = try decodeAs(type)
            return Future(object)
        } catch {
            let error = NSError(domain: "com.mobilejazz.json", code: 1, userInfo: [NSLocalizedDescriptionKey : "Failed to deserialize JSON"])
            return Future(error)
        }
    }
}

public extension Array where Element == [String : AnyObject] {
    public func decodeAs<T>() throws -> [T] where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let array = try JSONDecoder().decode(Array<T>.self, from: data)
        return array
    }
    
    public func decodeAs<T>() -> Future<[T]> where T : Decodable {
        do {
            let array : [T] = try decodeAs()
            return Future(array)
        } catch {
            let error = NSError(domain: "com.mobilejazz.json", code: 1, userInfo: [NSLocalizedDescriptionKey : "Failed to deserialize JSON"])
            return Future(error)
        }
    }
}
