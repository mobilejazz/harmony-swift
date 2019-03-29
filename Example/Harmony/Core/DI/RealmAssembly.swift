//
//  StorageAssembly.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Swinject
import Harmony
import RealmSwift

private enum RealmVersion : UInt64 {
    case AppRealmVersion0 = 0
    case AppRealmVersion1 = 1000
}

private let CurrentAppRealmVersion = RealmVersion.AppRealmVersion1.rawValue

class RealmAssembly: Assembly {

    func assemble(container: Container) {
        
        // Realm
        container.register(RealmFactory.self) { _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let configuration = Realm.Configuration(fileURL: URL(string:"\(documentsPath)/SwiftCore.realm"),
                                                    inMemoryIdentifier: nil,
                                                    syncConfiguration: nil,
                                                    encryptionKey: nil,
                                                    readOnly: false,
                                                    schemaVersion: CurrentAppRealmVersion,
                                                    migrationBlock: { (migration, version) in
                                                        // No migration to be done
            },
                                                    deleteRealmIfMigrationNeeded: false,
                                                    shouldCompactOnLaunch: nil,
                                                    objectTypes: [RealmItem.self, // <--- List here realm classes
                ])
            return RealmFactory(configuration: configuration,
                                minimumValidSchemaVersion: CurrentAppRealmVersion,
                                encryptionKeyName: "SwiftCore")
            }.inObjectScope(.container)
        
        container.register(RealmHandler.self) { r in RealmHandler(r.resolve(RealmFactory.self)!) }
    }
}
