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
			let data = json.description.data(using: .utf8)!
			let decoder = JSONDecoder()
			var itemEntity = try! decoder.decode(ItemEntity.self, from: data)
			itemEntity.lastUpdate = Date()
			
            return itemEntity
        })
    }
    
    private func getItems(_ query: AllItemsQuery) -> Future<[ItemEntity]> {
        let url = "/items"
        return sessionManager.request(url).validate().then(success: { (json) -> [ItemEntity]? in
            if let results = json["results"] as? [[String: AnyObject]] {
				let decoder = JSONDecoder()
				let jsonData = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
				let itemArray = try! decoder.decode(Array<ItemEntity>.self, from: jsonData)
				
				return itemArray.map({ item in
					var itemCopy = item
					itemCopy.lastUpdate = Date()
					return itemCopy
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
						let data = json.description.data(using: .utf8)!
						let decoder = JSONDecoder()
						var itemEntity = try! decoder.decode(ItemEntity.self, from: data)
						itemEntity.lastUpdate = Date()
                        
                        return itemEntity
                    })
                } else {
                    return nil
                }
            })
    }
}
