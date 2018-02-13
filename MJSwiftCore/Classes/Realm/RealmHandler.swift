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

///
/// The RealmHandler is the class responsible to generate read and write transactions and provide a realm instance.
///
public struct RealmHandler {
    
    private let realmFactory : RealmFactory
    
    /// Main init method
    ///
    /// - Parameter realmFactory: A realm factory.
    public init(_ realmFactory : RealmFactory) {
        self.realmFactory = realmFactory
    }
    
    /// Read method.
    ///
    /// - Parameter closure: A closure providing a realm to execute read queries.
    public func read(_ closure: (Realm) -> Void) {
        let realm = realmFactory.realm()
        closure(realm)
    }
    
    /// Write method.
    ///
    /// - Parameter closure: A closure providing a realm to execute write queries.
    /// - Throws: If error, the transaction is canceled and the error is thrown.
    public func write(_ closure: (Realm) -> Void) throws {
        let realm = realmFactory.realm()
        if realm.isInWriteTransaction {
            closure(realm)
        } else {
            realm.beginWrite()
            do {
                closure(realm)
                try realm.commitWrite()
                realm.refresh()
                NotificationCenter.default.post(name: NSNotification.Name(RealmHandlerDidCommitTransactionNotification),
                                                object: nil,
                                                userInfo: nil)
            } catch let error {
                realm.cancelWrite()
                throw error
            }
        }
    }
}
