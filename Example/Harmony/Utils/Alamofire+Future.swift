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

import Alamofire
import Foundation
import Harmony

public enum HarmonyAlamofireError: Error {
    case jsonSerialization
}

public extension DataRequest {
    /// Inserts the JSON data response into a Future with a mapping window
    func then<T>(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        success: @escaping (Any) throws -> T,
        failure: @escaping (Error, HTTPURLResponse?, Data?) -> Error = { error, _, _ in error }
    ) -> Future<T> {
        return Future<T> { resolver in
            self.validate()
                .response(queue: queue ?? .main,
                          responseSerializer: JSONResponseSerializer(options: options)) { response in
                    switch response.result {
                    case let .failure(error):
                        resolver.set(failure(error, response.response, response.data))
                    case let .success(data):
                        do {
                            resolver.set(try success(data))
                        } catch {
                            resolver.set(error)
                        }
                    }
                }
        }
    }

    /// Inserts the JSON data response into a Future
    func toFuture() -> Future<Any> {
        return then(queue: nil,
                    options: .allowFragments,
                    success: { $0 },
                    failure: { error, _, _ in error })
    }
}
