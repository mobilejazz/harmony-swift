//
// Created by Jose Luis  Franconetti Olmedo on 17/10/2017.
// Copyright (c) 2017 Defence Innovations PTY LTD. All rights reserved.
//

import Foundation

import Harmony
import Alamofire

extension ItemEntity {
    fileprivate static var fromNetworkMap : [String : String] {
        return ["image-url" : "imageURL"]
    }
    
    fileprivate static var toNetworkMap : [String : String] {
        return ["imageURL" : "image-url"]
    }
}

class ItemNetworkDataSource : GetDataSource  {
    
    typealias T = ItemEntity
    
    var sessionManager : Session
    
    required init(_ sessionManager: Session) {
        self.sessionManager = sessionManager
    }
    
    func get(_ query: Query) -> Future<ItemEntity> {
        switch query.self {
        case let query as IdQuery<String>:
            return getById(query.id)
        default:
            query.fatalError(.get, self)
        }
    }
    
    func getAll(_ query: Query) -> Future<[ItemEntity]> {
        switch query.self {
        case is AllItemsQuery, is AllObjectsQuery:
            return getAllItems()
        case is SearchItemsQuery:
            return searchItems((query as! SearchItemsQuery).text)
        default:
            query.fatalError(.getAll, self)
        }
    }
}

private extension ItemNetworkDataSource {
    private func getById(_ id: String) -> Future<ItemEntity> {
        let url = "/items/\(id)"
        return sessionManager.request(url).toFuture().flatMap { data -> Future<ItemEntity> in
            guard let json = data as? [String : AnyObject] else {
                throw CoreError.NotFound()
            }
            let future = json.decodeAs(ItemEntity.self, keyDecodingStrategy: .map(ItemEntity.fromNetworkMap)) { item in
                item.lastUpdate = Date()
            }
            return future
        }
    }
    
    private func getAllItems() -> Future<[ItemEntity]> {        
        let url = "/items"
        return sessionManager.request(url).toFuture().flatMap { data -> Future<[ItemEntity]> in
            guard let results = data as? [[String: AnyObject]] else {
                return Future([]) // or pass error if desired
            }
            return results.decodeAs(keyDecodingStrategy: .map(ItemEntity.fromNetworkMap), forEach: { item in
                item.lastUpdate = Date()
            })
        }
    }
    
    private func searchItems(_ text: String) -> Future<[ItemEntity]> {
        let url = "/items"
        return sessionManager.request(url,
                                      parameters: ["name" : text])
        .toFuture().flatMap { data -> Future<[ItemEntity]> in
                guard let json = data as? [String: AnyObject] else {
                    return Future([]) // no json to parse
                }
                guard let results = json["results"] as? [[String: AnyObject]] else {
                    return Future([]) // or pass error if desired
                }
                return results.decodeAs(keyDecodingStrategy: .map(ItemEntity.fromNetworkMap), forEach: { item in
                    item.lastUpdate = Date()
                })
        }
    }
}
