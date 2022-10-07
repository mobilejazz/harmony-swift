//
//  MockDecoder.swift
//  Harmony
//
//  Created by Kerim Sari on 26.09.2022.
//

import Foundation
import Harmony

@available(iOS 13.0, *)
class DecoderSpy: JSONDecoder {
    
    public var decodeCalledCount = 0
    public var forceFailure = false
    
    override var dateDecodingStrategy: DateDecodingStrategy {
        get {
            super.dateDecodingStrategy
        }
        set {
            super.dateDecodingStrategy = newValue
        }
    }
    
    override var dataDecodingStrategy: DataDecodingStrategy {
        get {
            super.dataDecodingStrategy
        }
        set {
            super.dataDecodingStrategy = newValue
        }
    }
    
    override var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy {
        get {
            super.nonConformingFloatDecodingStrategy
        }
        set {
            super.nonConformingFloatDecodingStrategy = newValue
        }
    }
    
    override var keyDecodingStrategy: KeyDecodingStrategy {
        get {
            super.keyDecodingStrategy
        }
        set {
            super.keyDecodingStrategy = newValue
        }
    }
    
    override var userInfo: [CodingUserInfoKey: Any] {
        get {
            super.userInfo
        }
        set {
            super.userInfo = newValue
        }
    }
        
    @available(iOS 15.0, *)
    override var allowsJSON5: Bool {
        get {
            super.allowsJSON5
        }
        set {
            super.allowsJSON5 = newValue
        }
    }
        
    @available(iOS 15.0, *)
    override var assumesTopLevelDictionary: Bool {
        get {
            super.assumesTopLevelDictionary
        }
        set {
            super.assumesTopLevelDictionary = newValue
        }
    }

    override init() {
        super.init()
    }

    override func decode<T>(_ type: T.Type, from: Input) throws -> T where T: Decodable {
        decodeCalledCount += 1
        if forceFailure {
            throw CoreError.Failed()
        } else {
            return try super.decode(type, from: from)
        }
    }
}
