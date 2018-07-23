//
//  ItemAssembly.swift
//  MJSwiftCore_Example
//
//  Created by Joan Martin on 23/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Swinject
import Alamofire
import RealmSwift
import MJSwiftCore

class ItemAssembly: Assembly {
    
    func assemble(container: Container) {

        // Network
        let sessionManager = container.resolve(SessionManager.self)!
        let itemNetworkGetDataSource = ItemNetworkDataSource(sessionManager) // <-- Only implements GetDataSource
        let itemNetworkDataSource = DataSourceAssambler(get: itemNetworkGetDataSource) // <-- Implements DataSource
        let networkDataSource = RetryDataSource(itemNetworkDataSource, retryCount: 1) { error in
            return error._code == NSURLErrorTimedOut && error._domain == NSURLErrorDomain
        }
        
        // Storage (Realm)
        let storageDataSource = RealmDataSource(realmHandler: container.resolve(RealmHandler.self)!,
                                                toEntityMapper: RealmItemToItemEntityMapper(),
                                                toRealmMapper: ItemEntityToRealmItemMapper())
        // Storage (In-Memory)
//        let storageDataSource = InMemoryDataSource<ItemEntity>()

        // Storage (UserDefaults)
//        let userDefaultsDataSource = UserDefaultsDataSource<Data>(UserDefaults.standard, prefix: "ItemEntity")
//        let storageDataSource = DataSourceMapper(dataSource: userDefaultsDataSource,
//                                                 toToMapper: EncodableToDataMapper<ItemEntity>(),
//                                                 toFromMapper: DataToDecodableMapper<ItemEntity>())
        
        // Storage (Keychain)
//        let keychainDataSource = KeychainDataSource<Data>(Keychain("com.mobilejazz.storage.item"))
//        let storageDataSource = DataSourceMapper(dataSource: keychainDataSource,
//                                                 toToMapper: EncodableToDataMapper<ItemEntity>(),
//                                                 toFromMapper: DataToDecodableMapper<ItemEntity>())
        
        // Vastra
        let vastra = VastraService([VastraTimestampStrategy()])
        let storageValidationDataSource = DataSourceValidator(dataSource: storageDataSource, validator: vastra)
        
        // Repository
        let networkStorageRepo = NetworkStorageRepository(network: networkDataSource,
                                                          storage: storageValidationDataSource)
        let repository = RepositoryMapper(repository: networkStorageRepo,
                                          toToMapper: EncodableToDecodableMapper<Item, ItemEntity>(), // ItemToItemEntityMapper(),
                                          toFromMapper: EncodableToDecodableMapper<ItemEntity, Item>()) // ItemEntityToItemMapper())
        
        // Interactors
        // container.register(Interactor.GetAllByQuery<Item>.self) { r in Interactor.GetAllByQuery<Item>(DispatchQueueExecutor(), repository) }
        container.register(Interactor.GetAll<Item>.self) { r in Interactor.GetAll<Item>(DispatchQueueExecutor(), repository, AllObjectsQuery()) }
    }
}
