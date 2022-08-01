//
//  MockObjectValidation.swift
//  HarmonyTests
//
//  Created by Joan Martin on 17/6/22.
//

import Foundation
import Harmony

/// Mock ObjectValidation implementation with custom return definition.
public struct MockObjectValidation<T>: ObjectValidation {
    public let objectValid: Bool
    public let arrayValid: Bool
    
    /// Default initializer.
    /// - Parameters:
    ///   - objectValid: The bool value to return upon object validation. Default value is true.
    ///   - arrayValid: The bool value to return upon array validation. Default value is true.
    public init(objectValid: Bool = true, arrayValid: Bool = true) {
        self.objectValid = objectValid
        self.arrayValid = arrayValid
    }
    
    public func isObjectValid<T>(_ object: T) -> Bool {
        return objectValid
    }
    
    public func isArrayValid<T>(_ objects: [T]) -> Bool {
        return arrayValid
    }
}
