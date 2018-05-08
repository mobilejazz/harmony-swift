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
// Provides a keychain service for a key value interface
//
public class KeychainDataSource<T> : DataSource<T> where T:Codable {
    
    private let keychain : Keychain
    
    public init(_ keychain : Keychain) {
        self.keychain = keychain
    }
    
    public override func get(_ query: Query) -> Future<T?> {
        guard let key = query.key() else {
            return super.get(query)
        }
        let value : T? = keychain.get(key)
        return Future(value)
    }
    
    public override func getAll(_ query: Query) -> Future<[T]> {
        guard let key = query.key() else {
            return super.getAll(query)
        }
        if let nsarray : NSArray = keychain.get(key) {
            let array = nsarray as! [T]
            return Future(array)
        }
        return Future([])
    }
    
    @discardableResult
    public override func put(_ value: T?, in query: Query) -> Future<T> {
        guard let key = query.key() else {
            return super.put(value, in: query)
        }
        let result = keychain.set(value!, forKey: key)
        switch result {
        case .success:
            return Future(value!)
        case .failed(_):
            return Future(result)
        }
    }
    
    @discardableResult
    public override func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        guard let key = query.key() else {
            return super.putAll(array, in: query)
        }
        let nsarray = array as NSArray
        let result = keychain.set(nsarray, forKey: key)
        switch result {
        case .success:
            return Future(array)
        case .failed(_):
            return Future(result)
        }
    }
    
    @discardableResult
    public override func delete(_ value: T?, in query: Query) -> Future<Bool> {
        guard let key = query.key() else {
            return super.delete(value, in: query)
        }
        let result = keychain.delete(key)
        switch result {
        case .success:
            return Future(true)
        case .failed(_):
            return Future(result)
        }
    }
    
    @discardableResult
    public override func deleteAll(_ array: [T], in query: Query) -> Future<Bool> {
        guard let key = query.key() else {
            return super.deleteAll(array, in: query)
        }
        let result = keychain.delete(key)
        switch result {
        case .success:
            return Future(true)
        case .failed(_):
            return Future(result)
        }
    }
}
