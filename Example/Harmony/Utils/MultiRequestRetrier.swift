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

public class MultiRequestRetrier: RequestRetrier {
    
    private var retriers : [RequestRetrier] = []
    
    public init(_ retriers : [RequestRetrier]) {
        self.retriers = retriers
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        should(0, session, retry: request, with: error, completion: completion)
    }
    
    private func should(_ index: Int, _ manager: Session, retry request: Request, with error: Error, completion: @escaping (RetryResult) -> Void) {
        if index < retriers.count {
            let retrier = retriers[index]
            retrier.retry(request, for: manager, dueTo: error) { retryResult in
                switch retryResult {                    
                case .retry, .retryWithDelay(_):
                    completion(retryResult)
                case .doNotRetry:
                    break
                case .doNotRetryWithError(_):
                    self.should(index+1, manager, retry: request, with: error, completion: completion)
                }
            }
        } else {
            completion(.doNotRetry)
        }
    }
}
