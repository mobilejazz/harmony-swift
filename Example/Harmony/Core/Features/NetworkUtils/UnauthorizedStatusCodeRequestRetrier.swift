//
//  401Handler.swift
//  SwiftCore
//
//  Created by Joan Martin on 15/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Alamofire

class UnauthorizedStatusCodeRequestRetrier: RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if request.response?.statusCode == 401 {
            // TODO: Logout user
        }
        completion(false, 0)
    }
}

