//
//  ItemAssembly.swift
//  Harmony_Example
//
//  Created by Joan Martin on 23/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Swinject
import Alamofire
import RealmSwift
import Harmony

class ItemAssembly: Assembly {
    
    func assemble(container: Container) {

        // Network
        let sessionManager = container.resolve(SessionManager.self)!
        let itemNetworkGetDataSource = ItemNetworkDataSource(sessionManager) // <-- Only implements GetDataSource
        let itemNetworkDataSource = DebugDataSource(DataSourceAssembler(get: itemNetworkGetDataSource),
                                                    delay: .sync(2),
                                                    error: .error(CoreError.Failed("Debug Fail"), probability: 0.02),
                                                    logger: DeviceConsoleLogger())
        let networkDataSource = RetryDataSource(itemNetworkDataSource, retryCount: 1) { error in
            return error._code == NSURLErrorTimedOut && error._domain == NSURLErrorDomain
        }
        
        // Storage (Realm)
//        let baseStorageDataSource = RealmDataSource(realmHandler: container.resolve(RealmHandler.self)!,
//                                                toEntityMapper: RealmItemToItemEntityMapper(),
//                                                toRealmMapper: ItemEntityToRealmItemMapper())
        // Storage (In-Memory)
        let baseStorageDataSource = InMemoryDataSource<ItemEntity>()

        // Storage (UserDefaults)
//        let userDefaultsDataSource = DeviceStorageDataSource<Data>(UserDefaults.standard, prefix: "ItemEntity")
//        let baseStorageDataSource = DataSourceMapper(dataSource: userDefaultsDataSource,
//                                                 toInMapper: EncodableToDataMapper<ItemEntity>(),
//                                                 toOutMapper: DataToDecodableMapper<ItemEntity>())
        
        // Storage (Keychain)
//        let keychainDataSource = KeychainDataSource<Data>(KeychainService("com.mobilejazz.storage.item"))
//        let baseStorageDataSource = DataSourceMapper(dataSource: keychainDataSource,
//                                                 toInMapper: EncodableToDataMapper<ItemEntity>(),
//                                                 toOutMapper: DataToDecodableMapper<ItemEntity>())
        
        
        let storageDataSource = DebugDataSource(baseStorageDataSource, logger: DeviceConsoleLogger())
        
        // Vastra
        let vastra = VastraService([VastraTimestampStrategy()])
        let storageValidationDataSource = DataSourceValidator(dataSource: storageDataSource, validator: vastra)
        
        // Repository
        let networkStorageRepo = CacheRepository(main: networkDataSource, cache: storageValidationDataSource)
        let repository = RepositoryMapper(repository: networkStorageRepo,
                                          toInMapper: EncodableToDecodableMapper<Item, ItemEntity>(), // ItemToItemEntityMapper(),
                                          toOutMapper: EncodableToDecodableMapper<ItemEntity, Item>()) // ItemEntityToItemMapper())
        
        // Interactors
        //container.register(Interactor.GetAllByQuery<Item>.self) { _ in repository.toGetAllByQueryInteractor(DispatchQueueExecutor()) }
        container.register(Interactor.GetAll<Item>.self) { _ in repository.toGetAllInteractor(DispatchQueueExecutor(), AllObjectsQuery()) }
    }
}
