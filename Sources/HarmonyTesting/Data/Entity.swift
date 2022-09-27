//
//  Entity.swift
//  Harmony
//
//  Created by Kerim Sari on 27.09.2022.
//

import Foundation

struct Entity: Codable {
    let name, owner: String
}

typealias EntityList = [Entity]
