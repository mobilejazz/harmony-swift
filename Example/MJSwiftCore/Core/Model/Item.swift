//
//  User.swift
//  SwiftCoreTests
//
//  Created by Joan Martin on 13/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore

struct Item : Model, Codable {
    let id: String?
    let name: String
    let price: Double
    let count: Int
    let imageURL: URL?
    
    init() {
        self.init(id: nil, name: "Blank", price: 0.0, count: 0, imageURL: nil)
    }
    
    init(id: String? = nil, name: String, price: Double, count: Int, imageURL: URL?) {
        self.id = id
        self.name = name
        self.price = price
        self.count = count
        self.imageURL = imageURL
    }
}
