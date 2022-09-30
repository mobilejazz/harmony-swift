//
//  GetAllItemsInteractor.swift
//  Harmony_Example
//
//  Created by Joan Martin on 22/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Harmony

struct GetAllItemsInteractor {
    let executor: Executor
    let getItems: Interactor.GetAllByQuery<Item>

    func execute(_ operation: Harmony.Operation = DefaultOperation()) -> Future<[Item]> {
        return executor.submit { r in
            let items = try self.getItems.execute(AllItemsQuery(), operation, in: DirectExecutor()).result.get()
            r.set(items)
        }
    }
}
