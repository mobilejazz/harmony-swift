//
// Created by Jose Luis  Franconetti Olmedo on 17/10/2017.
// Copyright (c) 2017 Defence Innovations PTY LTD. All rights reserved.
//

import Foundation

import Alamofire
import MJSwiftCore
import MJCocoaCore

class ItemNetworkService: AlamofireDataSource<ItemEntity> {
    
    override func get(_ query: Query) -> Future<ItemEntity> {
        switch query.self {
        case is QueryById<String>:
            return getById((query as! QueryById<String>).id)
        default:
            return super.get(query)
        }
    }
    
    override func getAll(_ query: Query) -> Future<[ItemEntity]> {
        switch query.self {
        case is AllObjectsQuery:
            return getAllItems()
        case is SearchItemsQuery:
            return searchItems((query as! SearchItemsQuery).text)
        default:
            return super.getAll(query)
        }
    }
}

private extension ItemNetworkService {
    private func getById(_ id: String) -> Future<ItemEntity> {
        let url = "/items/\(id)"
        return sessionManager.request(url).toFuture().flatMap { json in
            guard let json = json  else {
                return Future(CoreError.NotFound())
            }
            let future = json.decodeAs(ItemEntity.self) { item in
                item.lastUpdate = Date()
            }
            return future
        }
    }
    
    private func getAllItems() -> Future<[ItemEntity]> {        
        let url = "/items"
        return sessionManager.request(url).toFuture().flatMap { json in
            if let json = json {
                guard let results = json["results"] as? [[String: AnyObject]] else {
                    return Future([]) // or pass error if desired
                }
                return results.decodeAs(forEach: { item in
                    item.lastUpdate = Date()
                })
            }
            return Future([])
        }
    }
    
    private func searchItems(_ text: String) -> Future<[ItemEntity]> {
        let url = "/items"
        return sessionManager.request(url,
                                      parameters: ["name" : text])
            .toFuture().flatMap { json in
                if let json = json {
                    guard let results = json["results"] as? [[String: AnyObject]] else {
                        return Future([]) // or pass error if desired
                    }
                    return results.decodeAs(forEach: { item in
                        item.lastUpdate = Date()
                    })
                }
                return Future([])
        }
    }
}
