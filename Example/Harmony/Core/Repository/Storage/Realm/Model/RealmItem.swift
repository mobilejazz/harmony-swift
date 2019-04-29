//
//  RealmItem.swift
//  SwiftCore
//
//  Created by Joan Martin on 26/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Harmony
import RealmSwift

class RealmItem: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var price: Double = 0
    @objc dynamic var count: Int = 0
    @objc dynamic var lastUpdate: Date? = nil
    @objc dynamic var imageURL: String = ""
     
    public convenience init(_ id: String?) {
        self.init()
        if let id = id {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
    }
    
    @objc override open class func primaryKey() -> String? {
        return "id"
    }
}
