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

//
// Provides an in-memory service for a key value interface
//
public class InMemoryKeyValueService <T> : KeyValueInterface <T> {
    
    private var objects : [String : T] = [:]
    private var arrays : [String : [T]] = [:]
    
    public override init() {
        super.init()
    }
    
    public override func get(_ key: String) -> T? {
        let value = objects[key]
        return value
    }
    
    public override func getAll(_ key: String) -> [T]? {
        let array = arrays[key]
        return array
    }
    
    @discardableResult
    public override func set(_ value: T, forKey key: String) -> Bool {
        objects[key] = value
        arrays[key] = nil
        return true
    }
    
    @discardableResult
    public override func setAll(_ array: [T], forKey key: String) -> Bool {
        objects[key] = nil
        arrays[key] = array
        return true
    }
    
    @discardableResult
    public override func delete(_ key: String) -> Bool {
        objects[key] = nil
        arrays[key] = nil
        return true
    }
}

fileprivate var defaults = [String : Any]()

extension InMemoryKeyValueService {
    
    /// Returns a default instance for each T type
    public static var `default` : InMemoryKeyValueService<T> {
        get {
            let key = String(describing: T.self)
            if let instance = defaults[key] {
                return instance as! InMemoryKeyValueService<T>
            }
            let instance = InMemoryKeyValueService<T>()
            defaults[key] = instance
            return instance
        }
        set {
            let key = String(describing: T.self)
            defaults[key] = newValue
        }
    }
}
