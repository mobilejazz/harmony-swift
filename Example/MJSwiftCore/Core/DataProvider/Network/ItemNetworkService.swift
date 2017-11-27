//
// Created by Jose Luis  Franconetti Olmedo on 17/10/2017.
// Copyright (c) 2017 Defence Innovations PTY LTD. All rights reserved.
//

import Foundation

import Alamofire
import MJSwiftCore

class ItemNetworkService: Repository <ItemEntity> {
    
    let sessionManager : SessionManager
    
    init(_ sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        super.init()
    }
    
    override func get(_ query: Query) -> Future<[ItemEntity]> {
        switch query.self {
        case is QueryById:
            return get((query as! QueryById).id).map({ (entity) -> [ItemEntity] in
                return [entity]
            })
        case is AllItemsQuery:
            return getItems(query as! AllItemsQuery)
        case is SearchItemsQuery:
            return searchItems(query as! SearchItemsQuery)
        default:
            return super.get(query)
        }
    }
    
    // MARK: Private Methods
    
    private func get(_ id: String) -> Future<ItemEntity> {
        let url = "/items/\(id)"
        return sessionManager.request(url).validate().then(success: { (json) -> ItemEntity in
            let name = json["name"] as? String
            let price = json["price"] as? Double
            let count = json["count"] as? Int
            let imageURL = json["image-url"] as? String
            
            var itemEntity = ItemEntity(name: name!,
                                        price: price!,
                                        count: count!,
                                        imageURL: URL(string: imageURL!))
            itemEntity.lastUpdate = Date()
            
            return itemEntity
        })
    }
    
    private func getItems(_ query: AllItemsQuery) -> Future<[ItemEntity]> {
        let url = "/items"
        return sessionManager.request(url).validate().then(success: { (json) -> [ItemEntity]? in
            if let results = json["results"] as? [[String: AnyObject]] {
                return results.map({ (objects) -> ItemEntity in
                    let name = objects["name"] as? String
                    let price = objects["price"] as? Double
                    let count = objects["count"] as? Int
                    let imageURL = objects["image-url"] as? String
                    
                    var itemEntity = ItemEntity(name: name!,
                                                price: price!,
                                                count: count!,
                                                imageURL: URL(string: imageURL!))
                    itemEntity.lastUpdate = Date()
                    
                    return itemEntity
                })
            } else {
                return nil
            }
        })
    }
    
    private func searchItems(_ query: SearchItemsQuery) -> Future<[ItemEntity]> {
        let url = "/items"
        return sessionManager.request(url,
                                      parameters: ["name" : query.text])
            .validate().then(success: { (json) -> [ItemEntity]? in
                if let results = json["results"] as? [[String: AnyObject]] {
                    return results.map({ (objects) -> ItemEntity in
                        let name = objects["name"] as? String
                        let price = objects["price"] as? Double
                        let count = objects["count"] as? Int
                        let imageURL = objects["image-url"] as? String
                        
                        var itemEntity = ItemEntity(name: name!,
                                                    price: price!,
                                                    count: count!,
                                                    imageURL: URL(string: imageURL!))
                        itemEntity.lastUpdate = Date()
                        
                        return itemEntity
                    })
                } else {
                    return nil
                }
            })
    }
}
