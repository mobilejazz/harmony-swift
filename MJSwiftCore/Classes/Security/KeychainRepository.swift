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

///
/// Key-value based repository to store data in Keychain.
/// The repository only works with KeyQuery and KeyValueQuery types.
///
public class KeychainRepository <T> : Repository<T> where T:DataCodable, T:DataDecodable {
    
    public enum CustomError : Error {
        case failed(OSStatus)
        public var localizedDescription: String {
            switch self {
            case .failed(let status):
                return "Failed with status code: \(status)"
            }
        }
    }
    
    private let keychain : Keychain
    
    public init(_ keychain: Keychain) {
        self.keychain = keychain
    }
    
    
    public override func get(_ query: Query, operation: Operation) -> Future<T?> {
        switch query.self {
        case is KeyQuery:
            let value : T? = keychain.get((query as! KeyQuery).key)
            return Future(value)
        default:
            return super.get(query)
        }
    }
    
    public override func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        switch query.self {
        case is KeyQuery:
            fatalError("KeychainRepository does not support getAll with arrays. Use the standalone get(_:operation:) method to get a value")
        default:
            return super.getAll(query, operation: operation)
        }
    }
    
    public override func put(_ value: T, in query: Query, operation: Operation) -> Future<T> {
        switch query.self {
        case is KeyQuery:
            let keyQuery = (query as! KeyQuery)
            switch keychain.set(value, forKey: keyQuery.key) {
            case .success:
                return Future(value)
            case .failed(let status):
                return Future(CustomError.failed(status))
            }
        default:
            return super.put(value, in: query, operation: operation)
        }
    }

    public override func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        switch query.self {
        case is KeyQuery:
            fatalError("KeychainRepository does not support putAll with arrays. Use the standalone put(_:in:operation:) method to insert a value")
        default:
            return super.putAll(array, in: query, operation: operation)
        }
    }
    
    public override func delete(_ value: T?, in query: Query, operation: Operation) -> Future<Bool> {
        switch query.self {
        case is KeyQuery:
            switch keychain.delete((query as! KeyQuery).key) {
            case .success:
                return Future(true)
            case .failed(let status):
                return Future(CustomError.failed(status))
            }
        default:
            return super.delete(value, in: query, operation: operation)
        }
    }
    
    public override func deleteAll(_ array: [T], in query: Query, operation: Operation) -> Future<Bool> {
        switch query.self {
            case is KeyQuery:
                switch keychain.delete((query as! KeyQuery).key) {
                case .success:
                    return Future(true)
                case .failed(let status):
                    return Future(CustomError.failed(status))
                }
            default:
                return super.deleteAll(array, in: query, operation: operation)
        }
    }
}
