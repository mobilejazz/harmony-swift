//
//  ItemsQuery.swift
//  SwiftCore
//
//  Created by Joan Martin on 13/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import Foundation
import Harmony

class SearchItemsQuery: NetworkQuery {
    
    let text : String
    
    init(_ text: String) {
        self.text = text
        super.init(method: .get, path: "items", params: ["name":text])
    }
}

class AllItemsQuery: NetworkQuery {
    
    init() {
        super.init(method: .get, path: "items", key: "all-items")
    }
}




