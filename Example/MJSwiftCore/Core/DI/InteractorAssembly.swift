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
        //container.register(Executor.self) { _ in DispatchQueueExecutor(DispatchQueue(label: "com.mobilejazz.core.executor")) }
        container.register(Executor.self) { _ in
            let operationQueue = OperationQueue()
            operationQueue.name = "com.mobilejazz.core.executor"
            operationQueue.maxConcurrentOperationCount = 1
            return OperationQueueExecutor(operationQueue)
        }
        
        // Interactors
        container.register(GetItemsInteractor.self) { r in GetItemsInteractor(r.resolve(Executor.self)!, r.resolve(DataProvider<Item>.self)!) }
        container.register(SearchItemsInteractor.self) { r in SearchItemsInteractor(r.resolve(Executor.self)!, r.resolve(DataProvider<Item>.self)!) }
    }
}
