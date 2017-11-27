//
//  SearchItemsInteractor.swift
//  SwiftCore
//
//  Created by Joan Martin on 14/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore

struct SearchItemsInteractor {
    
    private let executor : Executor
    private let dataProvider : DataProvider<Item>
    
    init(_ executor: Executor, _ dataProvider: DataProvider<Item>) {
        self.executor = executor
        self.dataProvider = dataProvider
    }
    
    internal func execute(text: String) -> Future<[Item]> {
        return executor.submit({ (future) in
            future.set(self.dataProvider.get(SearchItemsQuery(text), operation: .network))
        })
    }
}
