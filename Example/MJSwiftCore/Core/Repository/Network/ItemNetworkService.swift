//
// Created by Jose Luis  Franconetti Olmedo on 17/10/2017.
// Copyright (c) 2017 Defence Innovations PTY LTD. All rights reserved.
//

import Foundation

import Alamofire
import MJSwiftCore

class ItemNetworkService: AlamofireRepository<ItemEntity> {
    
    override func get(_ query: Query, operation: MJSwiftCore.Operation) -> Future<ItemEntity?> {
        switch query.self {
        case is QueryById<String>:
            return getById((query as! QueryById<String>).id)
        default:
            return super.get(query, operation: operation)
        }
    }
    
    override func getAll(_ query: Query, operation: MJSwiftCore.Operation) -> Future<[ItemEntity]> {
        switch query.self {
        case is QueryById<String>:
            return getById((query as! QueryById<String>).id).map { [$0!] }
        case is AllObjectsQuery:
            return getAllItems()
        case is SearchItemsQuery:
            return searchItems((query as! SearchItemsQuery).text)
        default:
            return super.getAll(query, operation: operation)
        }
    }
}

private extension ItemNetworkService {
    private func getById(_ id: String) -> Future<ItemEntity?> {
        let url = "/items/\(id)"
        return sessionManager.request(url).toFuture().flatMap { json in
            if let json = json {
                let future = json.decodeAs(ItemEntity.self) { item in
                    item.lastUpdate = Date()
                }
                return future.optional()
            }
            return Future(nil)
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
