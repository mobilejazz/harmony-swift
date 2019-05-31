//
//  UserDefaults+Extension.swift
//  Harmony_Example
//
//  Created by Joan Martin on 27/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

extension UserDefaults {
    private func validate(_ dict : [String : Any] ) -> [String : Any] {
        var out = [String: Any]()
        for (key,value) in dict {
            switch value {
            case let value as Int:
                out[key] = value
            case let value as Double:
                out[key] = value
            case let value as [String : Any]:
                out[key] = validate(value)
            case let value as [Any]:
                out[key] = validate(value)
            default:
                out[key] = "\(value)"
            }
        }
        return out
    }
    
    private func validate(_ array : [Any] ) -> [Any] {
        var out = [Any]()
        for value in array {
            switch value {
            case let value as Int:
                out.append(value)
            case let value as Double:
                out.append(value)
            case let value as [String : Any]:
                out.append(validate(value))
            case let value as [Any]:
                out.append(validate(value))
            default:
                out.append("\(value)")
            }
        }
        return out
    }
    
    public func asJSONData() -> Data {
        let dict = validate(dictionaryRepresentation())
        return try! JSONSerialization.data(withJSONObject: dict , options: .prettyPrinted)
    }
    
    public func asJSONString() -> String {
        let jsonData = asJSONData()
        return String(data: jsonData, encoding: .utf8)!
    }
}
