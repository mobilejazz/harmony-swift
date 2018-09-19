//
// Created by Jose Luis  Franconetti Olmedo on 16/10/2017.
// Copyright (c) 2017 Defence Innovations PTY LTD. All rights reserved.
//

import Foundation

import MJSwiftCore

struct ItemEntity : RealmEntity, VastraTimestampStrategyDataSource, Codable {
    var id: String?
    var name: String
    var price: Double
    var count: Int
    var imageURL: URL?
	
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
    
	// MARK: VastraTimestampStrategyDataSource
    
	var lastUpdate: Date? = nil
    
    func expiryTimeInterval() -> Time {
        return .seconds(30)
    }
}

