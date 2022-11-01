//
//  Entity.swift
//  Harmony
//
//  Created by Kerim Sari on 27.09.2022.
//

import Foundation

public struct CodableEntity: Codable, Equatable {
    public let name, owner: String
}

public typealias EntityList = [CodableEntity]
