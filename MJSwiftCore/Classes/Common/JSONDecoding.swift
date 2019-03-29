//
// Copyright 2017 Mobile Jazz SL
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

public extension Dictionary where Key == String, Value == AnyObject {
    func decodeAs<T>(_ type : T.Type,
                            keyDecodingStrategy : JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> T where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        let object = try decoder.decode(type, from: data)
        return object
    }
    
    func decodeAs<T>(_ type : T.Type,
                            keyDecodingStrategy : JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                            completion: (inout T) -> Void = { _ in }) -> Future<T> where T : Decodable {
        do {
            var object : T = try decodeAs(type, keyDecodingStrategy: keyDecodingStrategy)
            completion(&object)
            return Future(object)
        } catch(let error) {
            return Future(error)
        }
    }
}

public extension Array where Element == [String : AnyObject] {
    func decodeAs<T>(keyDecodingStrategy : JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> [T] where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        let array = try decoder.decode(Array<T>.self, from: data)
        return array
    }
    
    func decodeAs<T>(keyDecodingStrategy : JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                            forEach: (inout T) -> Void = { _ in },
                            completion: (inout [T]) -> Void = { _ in }) -> Future<[T]> where T : Decodable {
        do {
            var array : [T] = try decodeAs(keyDecodingStrategy: keyDecodingStrategy)
            for index in array.indices {
                forEach(&(array[index]))
            }
            completion(&array)
            return Future(array)
        } catch(let error) {
            return Future(error)
        }
    }
}
