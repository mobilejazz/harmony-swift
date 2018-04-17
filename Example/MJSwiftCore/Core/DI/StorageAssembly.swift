//
//  StorageAssembly.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Swinject
import MJSwiftCore
import RealmSwift

private enum RealmVersion : UInt64 {
    case AppRealmVersion0 = 0
    case AppRealmVersion1 = 1000
}

private let CurrentAppRealmVersion = RealmVersion.AppRealmVersion1.rawValue

class StorageAssembly: Assembly {
    
    struct Names {
        static let storageRepository = "storage"
    }
    
    func assemble(container: Container) {
        
//        // Realm
//        container.register(RealmFactory.self) { _ in
//            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let configuration = Realm.Configuration.init(fileURL: URL(string:"\(documentsPath)/SwiftCore.realm"),
//                                                         inMemoryIdentifier: nil,
//                                                         syncConfiguration: nil,
//                                                         encryptionKey: nil,
//                                                         readOnly: false,
//                                                         schemaVersion: CurrentAppRealmVersion,
//                                                         migrationBlock: { (migration, version) in
//                                                            // No migration to be done
//            },
//                                                         deleteRealmIfMigrationNeeded: false,
//                                                         shouldCompactOnLaunch: nil,
//                                                         objectTypes: [RealmItem.self, // <--- List here realm classes
//                                                                       ])
//            return RealmFactory(configuration: configuration,
//                                minimumValidSchemaVersion: CurrentAppRealmVersion,
//                                encryptionKeyName: "SwiftCore")
//            }.inObjectScope(.container)
//        container.register(RealmHandler.self) { r in RealmHandler(r.resolve(RealmFactory.self)!) }
//
//        // Mappers
//        container.register(Mapper<RealmItem, ItemEntity>.self) { _ in RealmItemToItemEntityMapper() }
//        container.register(RealmMapper<ItemEntity, RealmItem>.self) { _ in ItemEntityToRealmItemMapper() }
//
//        // Storage Services
//        container.register(Repository<ItemEntity>.self, name: Names.storageRepository, factory: { r in
//            return RealmService(realmHandler: r.resolve(RealmHandler.self)!,
//                                toEntityMapper: r.resolve(Mapper<RealmItem, ItemEntity>.self)!,
//                                toRealmMapper: r.resolve(RealmMapper<ItemEntity, RealmItem>.self)!)
//        })
        
        container.register(Repository<ItemEntity>.self, name: Names.storageRepository, factory: { r in
//            let keyValueService : KeyValueInterface<ItemEntity> = InMemoryKeyValueService<ItemEntity>()
//            let repository = KeyValueRepository<ItemEntity>(keyValueService)
            
            let userDefaultsService = UserDefaultsKeyValueService<Data>(UserDefaults.standard, keyPrefix: "ItemEntity")
            let dataRepository = KeyValueRepository<Data>(userDefaultsService)
            let repository = RepositoryMapper<ItemEntity, Data>(repository: dataRepository,
                                                                toToMapper: EncodableToDataMapper<ItemEntity>(),
                                                                toFromMapper: DataToDecodableMapper<ItemEntity>())
            return repository
        })
    }
}
