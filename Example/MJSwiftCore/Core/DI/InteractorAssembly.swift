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
        container.register(Executor.self, name: "GetItems") { r in DispatchQueueExecutor() }.inObjectScope(.container)
        
        // Interactors
        container.register(GetObjectsInteractor<Item>.self) { r in GetObjectsInteractor<Item>(r.resolve(Executor.self, name: "GetItems")!,
                                                                                              r.resolve(DataProvider<Item>.self)!) }
    }
}
