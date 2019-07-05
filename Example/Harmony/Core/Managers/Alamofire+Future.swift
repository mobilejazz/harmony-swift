//
//  Alamofire+Future.swift
//  SwiftCore
//
//  Created by Joan Martin on 09/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//


import Alamofire
import Harmony

public extension DataRequest {
    /// Inserts the JSON data response into a Future
    func toFuture() -> Future<Any> {
        return then(queue: nil,
                    options: .allowFragments,
                    success: { $0 },
                    failure: { error, _, _ in error })
    }
}
