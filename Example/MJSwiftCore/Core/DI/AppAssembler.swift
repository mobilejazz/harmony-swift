//
//  AppAssembler.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Swinject

class AppAssembler {
    static let assembler : Assembler = Assembler([StorageAssembly(),
                                                  NetworkAssembly(),
                                                  DataProviderAssembly(),
                                                  InteractorAssembly()])
    
    static var resolver : Resolver {
        return assembler.resolver
    }
}

//        let realmConfiguration : Realm.Configuration = Realm.Configuration()
//        let realmHandler : RealmHandler = RealmHandler(realmConfiguration)
//        let realmService : RealmService<ItemEntity,RealmItem> = RealmService(realmHandler: realmHandler,
//                                                                             toEntityMapper: RealmItemToItemEntityMapper(),
//                                                                             toRealmMapper: ItemEntityToRealmItemMapper())
//
//        // Creating dependencies
//        let itemNetworkClient: ItemNetworkClient = ItemNetworkService()
//        let itemStorageClient: ItemStorageClient = ItemStorageRealmService(realmService: realmService)
//
//        // Creating data provider
//        let itemDataProvider = ItemDataProvider(network: itemNetworkClient,
//                                                storage: itemStorageClient,
//                                                toItemEntityMapper: ItemToItemEntityMapper(),
//                                                toItemMapper: ItemEntityToItemMapper())
//
//
//        // Creating interactor
//        let executor : Executor = DispatchQueueExecutor(DispatchQueue(label: "com.mobilejazz.core.executor"))
//        let getItemsInteractor = GetItemsInteractor(executor, itemDataProvider)

