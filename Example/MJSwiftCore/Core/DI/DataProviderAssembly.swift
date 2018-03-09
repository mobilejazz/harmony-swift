//
//  DataProviderAssembly.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

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
        container.register(DataProvider<Item>.self) { r in
            return NetworkStorageDataProvider(network: r.resolve(Repository<ItemEntity>.self, name: NetworkAssembly.Names.networkRepository)!,
                                       storage: r.resolve(Repository<ItemEntity>.self, name: StorageAssembly.Names.storageRepository)!,
                                       storageValidation: r.resolve(ObjectValidation.self, name: Names.storageValidation)!,
                                       toEntityMapper: r.resolve(Mapper<Item, ItemEntity>.self)!,
                                       toObjectMapper: r.resolve(Mapper<ItemEntity, Item>.self)!)
            }.inObjectScope(.container)
    }
}

// Make Vastra compliant with ObjectValidation
extension VastraService : ObjectValidation { }
