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
    public func decodeAs<T>(_ type : T.Type) throws -> T where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let object = try JSONDecoder().decode(type, from: data)
        return object
    }
    
    public func decodeAs<T>(_ type : T.Type, completion: (inout T) -> Void = { _ in }) -> Future<T> where T : Decodable {
        do {
            var object : T = try decodeAs(type)
            completion(&object)
            return Future(object)
        } catch(let error) {
            return Future(error)
        }
    }
}

public extension Array where Element == [String : AnyObject] {
    public func decodeAs<T>() throws -> [T] where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let array = try JSONDecoder().decode(Array<T>.self, from: data)
        return array
    }
    
    public func decodeAs<T>(forEach: (inout T) -> Void = { _ in }, completion: (inout [T]) -> Void = { _ in }) -> Future<[T]> where T : Decodable {
        do {
            var array : [T] = try decodeAs()
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
