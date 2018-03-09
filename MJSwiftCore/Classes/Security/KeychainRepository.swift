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

public class KeychainRepository <T:DataConvertible> : Repository<T> {
    
    public enum CustomError : Error {
        case failed(OSStatus)
    }
    
    private let keychain : Keychain
    
    public init(_ keychain: Keychain) {
        self.keychain = keychain
    }
    
    public override func getAll(_ query: Query) -> Future<[T]> {
        switch query.self {
        case is KeyQuery:
            guard let value : T = keychain.get((query as! KeyQuery).key) else {
                return Future([])
            }
            return Future([value])
        default:
            return super.getAll(query)
        }
    }

    public override func putAll(_ entities: [T]) -> Future<[T]> {
        fatalError("KeychainRepository only accepts PUT actions using queries. Please, use method put(_ query: Query) with a KeyValueQuery instead.")
    }
    
    public override func put(_ query: Query) -> Future<Bool> {
        switch query.self {
        case is KeyValueQuery<T>:
            let keyValueQuery = (query as! KeyValueQuery<T>)
            switch keychain.set(keyValueQuery.value, forKey: keyValueQuery.key) {
            case .success:
                return Future(true)
            case .failed(let status):
                return Future(CustomError.failed(status))
            }
        default:
            return super.put(query)
        }
    }
    
    public override func delete(_ query: Query) -> Future<Bool> {
        switch query.self {
            case is KeyQuery:
                switch keychain.delete((query as! KeyQuery).key) {
                case .success:
                    return Future(true)
                case .failed(let status):
                    return Future(CustomError.failed(status))
                }
            default:
                return super.delete(query)
        }
    }

    public override func deleteAll(_ entities: [T]) -> Future<Bool> {
        fatalError("KeychainRepository only accepts DELETE actions using queries. Please, use method delete(_ query: Query) with a KeyQuery instead.")
    }
}
