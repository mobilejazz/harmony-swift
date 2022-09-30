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
    func retry(_ request: Request, for _: Session, dueTo _: Error, completion: @escaping (RetryResult) -> Void) {
        if request.response?.statusCode == 401 {
            // TODO: Logout user
        }
        completion(.doNotRetry)
    }
}
