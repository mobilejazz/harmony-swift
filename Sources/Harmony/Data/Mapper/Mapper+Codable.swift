//
// Copyright 2018 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public class EncodableToDataMapper <T> : Mapper <T, Data> where T: Encodable {
    private let mapping : [String : String]
    
    public init(_ mapping : [String : String] = [:]) {
        self.mapping = mapping
    }
    
    public override func map(_ from: T) -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .map(mapping)
        let data = try! encoder.encode(from)
        return data
    }
}

public class DataToDecodableMapper <T> : Mapper <Data, T> where T: Decodable {
    private let mapping : [String : String]
    
    public init(_ mapping : [String : String] = [:]) {
        self.mapping = mapping
    }
    
    public override func map(_ from: Data) -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .map(mapping)
        let value = try! decoder.decode(T.self, from: from)
        return value
    }
}

public class EncodableToDecodableMapper <E,D> : Mapper <E, D> where D: Decodable, E: Encodable {
    
    private let mapping : [String : String]
    
    public init(_ mapping : [String : String] = [:]) {
        self.mapping = mapping
    }
    
    public override func map(_ from: E) -> D {
        let encoder = JSONEncoder()
        // Encoding to a format that is readable by the decoder
        encoder.keyEncodingStrategy = .map(mapping)
        let data = try! encoder.encode(from)
        
        let decoder = JSONDecoder()
        // No need to customize the keyDecodingStrategy
        let value = try! decoder.decode(D.self, from: data)
        return value
    }
}
