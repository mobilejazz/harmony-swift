//
//  EntityObjectMother.swift
//  Harmony
//
//  Created by Borja Arias Drake on 21.10.2022..
//

import Foundation

public func anyEntity() -> CodableEntity {
    CodableEntity(name: anyString(), owner: anyString())
}
