//
// Copyright 2018 Mobile Jazz SL
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

// MARK: - Constants

struct Constants {
    static let iterationCount = 10_000
}

// MARK: - Helpers

func print(average time: UInt64) {
    print(String(format: "Average time: %.10lf", Double(time) / Double(NSEC_PER_SEC)))
}

func print(total time: TimeInterval) {
    print(String(format: "Total time: %.10lf", time))
}

