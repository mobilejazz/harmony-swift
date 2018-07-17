//
//  DataProviderAssembly.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import Foundation

import Swinject
import MJSwiftCore

class RepositoryAssembly: Assembly {
    
    struct Names {
        static let storageValidation = "storageValidation"
    }
    
    func assemble(container: Container) {
        // Vastra
        container.register(ObjectValidation.self, name: Names.storageValidation) { _ in
            return VastraService([VastraTimestampStrategy()])
        }
        
        // Mappers
//        container.register(Mapper<Item, ItemEntity>.self) { _ in ItemToItemEntityMapper() }
//        container.register(Mapper<ItemEntity, Item>.self) { _ in ItemEntityToItemMapper() }
        
        container.register(Mapper<Item, ItemEntity>.self) { _ in EncodableToDecodableMapper() }
        container.register(Mapper<ItemEntity, Item>.self) { _ in EncodableToDecodableMapper() }
        
        // Data Providers (registered as singletons)
        container.register(AnyRepository<Item>.self) { r in
            let storageDataSource = r.resolve(AnyDataSource<ItemEntity>.self, name: StorageAssembly.Names.storageRepository)!
            let storageValidationDataSource = DataSourceValidator(dataSource: storageDataSource,
                                                                  validator: r.resolve(ObjectValidation.self, name: Names.storageValidation)!)
            let networkDataSource = r.resolve(AnyGetDataSource<ItemEntity>.self, name: NetworkAssembly.Names.networkRepository)!
            let networkStorageRepo = NetworkStorageRepository(network: DataSourceAssambler(get: networkDataSource),
                                                              storage: storageValidationDataSource)
            
            return RepositoryMapper(repository: networkStorageRepo,
                                    toToMapper: r.resolve(Mapper<Item,ItemEntity>.self)!,
                                    toFromMapper: r.resolve(Mapper<ItemEntity,Item>.self)!).asAnyRepository()
            
            }.inObjectScope(.container)
    }
}

// Make Vastra compliant with ObjectValidation
extension VastraService : ObjectValidation { }
