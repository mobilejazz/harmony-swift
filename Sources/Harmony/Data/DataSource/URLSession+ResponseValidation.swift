//
//  URLSession.swift
//  Harmony
//
//  Created by Borja Arias Drake on 31.10.2022..
//

import Foundation


func validateResponse(response: URLResponse?,
                      responseData: Data?,
                      responseError: Error?,
                      successfulValidation: @escaping (_: Data)->(),
                      failedValidation: @escaping (_: Error)->()) {
    guard let responseData else {
        failedValidation(CoreError.DataSerialization())
        return
    }
    guard let httpResponse = response as? HTTPURLResponse else {
        failedValidation(CoreError.Failed())
        return
    }
    guard responseError == nil else {
        failedValidation(responseError!)
        return
    }
    
    let statusCode = httpResponse.statusCode
    guard (200 ... 299) ~= statusCode else {
        failedValidation(CoreError.Failed("HTTP status code: \(statusCode)"))
        return
    }
    
    return successfulValidation(responseData)
}
