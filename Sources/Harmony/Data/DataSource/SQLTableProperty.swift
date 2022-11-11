//
//  SQLTableProperty.swift
//  Harmony
//
//  Created by Borja Arias Drake on 26.10.2022..
//

import Foundation
import SQLite

public struct SQLTableColumn<T: Value>: SQLValueExpression {
    public typealias V = T
    public let name: String
    public let type: T.Type
    public let isTypeOptional: Bool
    public var identifier: String { name }
        
    public init(name: String, type: T.Type, isTypeOptional: Bool = false) {
        self.name = name
        self.type = type
        self.isTypeOptional = isTypeOptional
    }
}

public protocol SQLValueExpression {
    associatedtype V: Value
    var identifier: String {get}
    var isTypeOptional: Bool {get}
}
