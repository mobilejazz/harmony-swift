//
//  Product.swift
//  SwiftCore
//
//  Created by Joan Martin on 16/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore

struct Product : Model {
    let id: String?
    let price: Double
    let name: String
    
    init() {
        id = nil
        price = 0.0
        name = ""
    }
    
    init(id: String? = nil, price: Double, name: String) {
        self.id = id
        self.price = price
        self.name = name
    }
}
