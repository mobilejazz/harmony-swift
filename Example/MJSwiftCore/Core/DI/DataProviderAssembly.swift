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

class DataProviderAssembly: Assembly {
    
    struct Names {
        static let storageValidation = "storageValidation"
    }
    
    func assemble(container: Container) {
        // Vastra
        container.register(ObjectValidation.self, name: Names.storageValidation) { _ in
            return VastraService([VastraTimestampStrategy()])
        }
        
        // Mappers
        container.register(Mapper<Item, ItemEntity>.self) { _ in ItemToItemEntityMapper() }
        container.register(Mapper<ItemEntity, Item>.self) { _ in ItemEntityToItemMapper() }
        
        // Data Providers (registered as singletons)
        container.register(Repository<Item>.self) { r in
            let storageEntityRepo = r.resolve(Repository<ItemEntity>.self, name: StorageAssembly.Names.storageRepository)!
            let storageValidationRepo = RepositoryValidator(repository: storageEntityRepo,
                                                            validator: r.resolve(ObjectValidation.self, name: Names.storageValidation)!)
            
            let networkStorageRepo = NetworkStorageRepository(network: r.resolve(Repository<ItemEntity>.self, name: NetworkAssembly.Names.networkRepository)!,
                                                              storage: storageValidationRepo)
            
            return RepositoryMapper(repository: networkStorageRepo,
                                    toToMapper: r.resolve(Mapper<Item,ItemEntity>.self)!,
                                    toFromMapper: r.resolve(Mapper<ItemEntity,Item>.self)!)
            
            }.inObjectScope(.container)
    }
}

// Make Vastra compliant with ObjectValidation
extension VastraService : ObjectValidation { }
