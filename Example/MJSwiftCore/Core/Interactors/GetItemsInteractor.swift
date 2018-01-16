//
//  GetItemsInteractor.swift
//  SwiftCore
//
//  Created by Joan Martin on 16/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore

struct GetItemsInteractor {
    
    private let executor : Executor
    private let dataProvider: DataProvider<Item>
    private let validator: VastraService = VastraService([])

    init(_ executor: Executor, _ dataProvider: DataProvider<Item>) {
        self.executor = executor
        self.dataProvider = dataProvider
    }

    internal func execute(_ operation: MJSwiftCore.Operation = .storageSync) -> Future<[Item]> {
        return executor.submit { future in
            future.set(self.dataProvider.get(AllItemsQuery(), operation: operation))
        }
    }
}
