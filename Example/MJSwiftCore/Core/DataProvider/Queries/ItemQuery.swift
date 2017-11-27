//
//  ItemsQuery.swift
//  SwiftCore
//
//  Created by Joan Martin on 13/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore

class AllItemsQuery : Query {
    // Empty implementation
}

class SearchItemsQuery: Query {
    let text : String
    init(_ text: String) {
        self.text = text
    }
}
