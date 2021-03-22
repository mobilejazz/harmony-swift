//
//  OAuth2RetryHandler.swift
//  SwiftCore
//
//  Created by Joan Martin on 09/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Alamofire
import Harmony

// https://github.com/p2/OAuth2/wiki/Alamofire-4

//class OAuth2RetryHandler: RequestRetrier, RequestAdapter {
//
//    let loader: OAuth2DataLoader
//    
//    init(oauth2: OAuth2) {
//        loader = OAuth2DataLoader(oauth2: oauth2)
//    }
//    
//    /// Intercept 401 and do an OAuth2 authorization.
//    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
//        if let response = request.task?.response as? HTTPURLResponse, 401 == response.statusCode, let req = request.request {
//            var dataRequest = OAuth2DataRequest(request: req, callback: { _ in })
//            dataRequest.context = completion
//            loader.enqueue(request: dataRequest)
//            loader.attemptToAuthorize() { authParams, error in
//                self.loader.dequeueAndApply() { req in
//                    if let comp = req.context as? RequestRetryCompletion {
//                        comp(nil != authParams, 0.0)
//                    }
//                }
//            }
//        }
//        else {
//            completion(false, 0.0)   // not a 401, not our problem
//        }
//    }
//    
//    /// Sign the request with the access token.
//    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
//        guard nil != loader.oauth2.accessToken else {
//            return urlRequest
//        }
//        
//        return try urlRequest.signed(with: loader.oauth2)   // "try" added in 3.0.2
//    }
//}
