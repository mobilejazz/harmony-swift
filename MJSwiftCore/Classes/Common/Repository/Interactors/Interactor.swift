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

// Namespace definition
public struct Interactor { }

///
/// Convenience superclass for interactors
///
open class QueryInteractor<T> {

    public let executor : Executor
    public let repository: AnyRepository<T>
    
    public required init(_ executor: Executor, _ repository: AnyRepository<T>) {
        self.executor = executor
        self.repository = repository
    }
}

///
/// Convenience superclass for interactors
///
open class DirectInteractor<T> : QueryInteractor <T>{
    public let query : Query
    
    @available(*, unavailable)
    public required init(_ executor: Executor, _ repository: AnyRepository<T>) {
        self.query = BlankQuery()
        super.init(executor, repository)
    }
    
    public required init(_ executor: Executor, _ repository: AnyRepository<T>, _ query: Query) {
        self.query = query
        super.init(executor, repository)
    }
    
    public convenience init<K>(_ executor: Executor, _ repository: AnyRepository<T>, _ id: K) where K:Hashable {
        self.init(executor, repository, IdQuery(id))
    }
}

