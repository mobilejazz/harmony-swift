//
// Created by Jose Luis  Franconetti Olmedo on 16/10/2017.
// Copyright (c) 2017 Defence Innovations PTY LTD. All rights reserved.
//

import Foundation

import Harmony

class ItemToItemEntityMapper: Mapper<Item, ItemEntity> {
    override func map(_ from: Item) throws -> ItemEntity {
        return ItemEntity(
            id: from.id,
            name: from.name,
            price: from.price,
            count: from.count,
            imageURL: from.imageURL
        )
    }
}

class ItemEntityToItemMapper: Mapper<ItemEntity, Item> {
    override func map(_ from: ItemEntity) throws -> Item {
        return Item(id: from.id, name: from.name, price: from.price, count: from.count, imageURL: from.imageURL)
    }
}
