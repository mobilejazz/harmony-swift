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

///
/// Generic get object interactor
///
public struct GetObjectInteractor <T> {
    
    private let executor : Executor
    private let dataProvider: DataProvider<T>
    
    public init(_ executor: Executor, _ dataProvider: DataProvider<T>) {
        self.executor = executor
        self.dataProvider = dataProvider
    }
    
    public func execute(_ query: Query, _ operation: Operation) -> Future<T?> {
        return executor.submit { future in
            future.set(self.dataProvider.get(query, operation: operation))
        }
    }
}
