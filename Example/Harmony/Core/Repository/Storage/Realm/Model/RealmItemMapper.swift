//
//  RealmItemMapper.swift
//  SwiftCore
//
//  Created by Joan Martin on 26/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Harmony
import RealmSwift

class RealmItemToItemEntityMapper: Mapper<RealmItem, ItemEntity> {
    override func map(_ from: RealmItem) -> ItemEntity {
        var item = ItemEntity(id: from.id,
                              name: from.name,
                              price: from.price,
                              count: from.count,
                              imageURL: URL(string: from.imageURL))
        item.lastUpdate = from.lastUpdate
        return item
    }
}

class ItemEntityToRealmItemMapper: RealmMapper <ItemEntity, RealmItem> {
    override func map(_ from: ItemEntity, inRealm realm: Realm) -> RealmItem {
        let id = from.id != nil ? from.id : RealmItem.findId(key: "name", value: from.name, inRealm: realm)
        let object = RealmItem(id)
        object.name = from.name
        object.price = from.price
        object.count = from.count
        object.imageURL = from.imageURL!.absoluteString
        object.lastUpdate = from.lastUpdate
        return object
    }
}
