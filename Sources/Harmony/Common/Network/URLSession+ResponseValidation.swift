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

func validateResponse(response: URLResponse?,
                      responseData: Data?,
                      responseError: Error?,
                      successfulValidation: @escaping (_: Data)->(),
                      failedValidation: @escaping (_: Error)->())
{
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
