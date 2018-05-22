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
    
    public override func get(_ query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            guard let value : T = keychain.get(query.key) else {
                return Future(CoreError.NotFound())
            }
            return Future(value)
        default:
            return super.get(query)
        }
    }
    
    public override func getAll(_ query: Query) -> Future<[T]> {
        switch query {
        case let query as KeyQuery:
            guard let nsarray : NSArray = keychain.get(query.key) else {
                return Future(CoreError.NotFound())
            }
            guard let array = nsarray as? [T] else {
                return Future(CoreError.Failed("NSArray to Array<\(String(describing:T.self))> cast failed for key \(query.key)"))
            }
            return Future(array)
        default:
            return super.getAll(query)
        }
    }
    
    @discardableResult
    public override func put(_ value: T?, in query: Query) -> Future<T> {
        switch query {
        case let query as KeyQuery:
            guard let value = value else {
                return Future(CoreError.IllegalArgument("Value cannot be nil for key \(query.key)"))
            }
            switch keychain.set(value, forKey: query.key) {
            case .success:
                return Future(value)
            case .failed(let status):
                return Future(CoreError.OSStatusFailure(status, "Keychain failed to set value for key \(query.key) (OSStatus \(status))"))
            }
        default:
            return super.put(value, in: query)
        }
    }
    
    @discardableResult
    public override func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        switch query {
        case let query as KeyQuery:
            let nsarray = array as NSArray
            switch keychain.set(nsarray, forKey: query.key) {
            case .success:
                return Future(array)
            case .failed(let status):
                return Future(CoreError.OSStatusFailure(status, "Keychain failed to set value for key \(query.key) (OSStatus \(status))"))
            }
        default:
            return super.putAll(array, in: query)
        }
    }
    
    @discardableResult
    public override func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            switch keychain.delete(query.key) {
            case .success:
                return Future(Void())
            case .failed(let status):
                return Future(CoreError.OSStatusFailure(status, "Keychain failed to delete value for key \(query.key) (OSStatus \(status))"))
            }
        default:
            return super.delete(query)
        }
    }
    
    @discardableResult
    public override func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            switch keychain.delete(query.key) {
            case .success:
                return Future(Void())
            case .failed(let status):
                return Future(CoreError.OSStatusFailure(status, "Keychain failed to delete value for key \(query.key) (OSStatus \(status))"))
            }
        default:
            return super.deleteAll(query)
        }
    }
}
