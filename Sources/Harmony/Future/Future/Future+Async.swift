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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implOied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

extension Future {
    @available(iOS 13.0.0, *)
    /// Returns the future's value using the async/await pattern
    /// - Returns: Returns the value, or throws an error.
    func async() async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            self.then { continuation.resume(returning: $0) }
                .fail { continuation.resume(throwing: $0) }
        }
    }
}
