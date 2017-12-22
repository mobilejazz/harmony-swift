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
import RealmSwift

public let RealmHandlerDidCommitTransactionNotification = "com.mobilejazz.RealmHandlerDidCommitTransactionNotification"

public struct RealmHandler {
    
    private let realmFactory : RealmFactory
    
    public init(_ realmFactory : RealmFactory) {
        self.realmFactory = realmFactory
    }
    
    public func read<T>(_ closure: (Realm) -> T?) -> Future<T> {
        let realm = realmFactory.realm()
        return Future<T>(closure(realm))
    }
    
    public func write<T>(_ closure: (Realm) -> T?) -> Future<T> {
        let future = Future<T>()
        let realm = realmFactory.realm()
        if realm.isInWriteTransaction {
            future.set(closure(realm))
        } else {
            realm.beginWrite()
            do {
                let result = closure(realm)
                try realm.commitWrite()
                realm.refresh()
                future.set(result)
                NotificationCenter.default.post(name: NSNotification.Name(RealmHandlerDidCommitTransactionNotification), object: nil, userInfo: nil)
            } catch let error {
                realm.cancelWrite()
                future.set(error)
            }
        }
        return future
    }
}
