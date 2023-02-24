//
//  GetAllItemsInteractor.swift
//  Harmony_Example
//
//  Created by Joan Martin on 22/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Harmony

struct GetAllItemsInteractor {
    let getItems: AsyncGetAllInteractor<Item>
    
    func execute(_ operation: Harmony.Operation = DefaultOperation()) async throws -> [Item] {
        return try await self.getItems.execute(AllItemsQuery(), operation)

    }
}
