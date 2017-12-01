//
//  InteractorAssembly.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Swinject
import MJSwiftCore

class InteractorAssembly: Assembly {
    
    func assemble(container: Container) {
        // Executor
        container.register(Executor.self, name: "GetItemsInteractor") { r in DispatchQueueExecutor() }.inObjectScope(.container)
        container.register(Executor.self, name: "SearchItemsInteractor") { r in DispatchQueueExecutor() }.inObjectScope(.container)
        
        // Interactors
        container.register(GetItemsInteractor.self) { r in GetItemsInteractor(r.resolve(Executor.self, name: "GetItemsInteractor")!,
                                                                              r.resolve(DataProvider<Item>.self)!) }
        container.register(SearchItemsInteractor.self) { r in SearchItemsInteractor(r.resolve(Executor.self, name: "SearchItemsInteractor")!,
                                                                                    r.resolve(DataProvider<Item>.self)!) }
    }
}
