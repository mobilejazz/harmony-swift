//
//  NoResponse.swift
//  Harmony
//
//  Created by Borja Arias Drake on 14.10.2022..
//

import Foundation


/// This exists to work well with the Future<T> APIs, which always expect a value to be returned in case of success.
public struct NoResponse: Codable, Equatable {
    public init() {}
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}
