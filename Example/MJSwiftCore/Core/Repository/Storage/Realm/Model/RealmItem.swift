//
//  RealmItem.swift
//  SwiftCore
//
//  Created by Joan Martin on 26/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore
import RealmSwift

class RealmItem: RealmObject {
    @objc dynamic var name: String = ""
    @objc dynamic var price: Double = 0
    @objc dynamic var count: Int = 0
    @objc dynamic var lastUpdate: Date? = nil
    @objc dynamic var imageURL: String = ""
}
