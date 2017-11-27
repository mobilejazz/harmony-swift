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

public class RealmFactory {
    
    private var configuration : Realm.Configuration
    
    public init(configuration config: Realm.Configuration, minimumValidSchemaVersion: UInt64 = 0, encryptionKeyName: String? = nil) {
        configuration = config
        
        var encryptionKey : Data?
        
        if let encryptionKeyName = encryptionKeyName {
            encryptionKey = SecureKey(identifier: encryptionKeyName).key()
            configuration.encryptionKey = encryptionKey
        } else {
            configuration.encryptionKey = nil
        }
        
        if minimumValidSchemaVersion > 0 {
            if let fileURL = configuration.fileURL {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    let currentVersion = try! schemaVersionAtURL(fileURL, encryptionKey: encryptionKey)
                    if currentVersion < minimumValidSchemaVersion {
                        try! FileManager.default.removeItem(at: fileURL)
                    }
                }
            }
        }
        
        if let fileURL = configuration.fileURL {
            NSLog("Realm Path: \(fileURL)")
        }
    }
    
    public func realm() -> Realm {
        let realm = try! Realm(configuration: configuration)
        return realm
    }
}
