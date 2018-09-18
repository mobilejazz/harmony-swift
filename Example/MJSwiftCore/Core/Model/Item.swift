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
}
