//
// Copyright 2022 Mobile Jazz SL
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

import Alamofire
import Foundation

open class GetNetworkDataSource<T: Decodable>: GetDataSource {
    
    private let url: String
    private let session: Session
    private let decoder: JSONDecoder
    
    public init(url: String, session: Session, decoder: JSONDecoder) {
        self.url = url
        self.session = session
        self.decoder = decoder
    }
    
    @discardableResult
    open func getAll(_ query: Query) -> Future<[T]> {
        return execute(query)
    }
    
    @discardableResult
    open func get(_ query: Query) -> Future<T> {
        return execute(query)
    }
    
    private func execute<K: Decodable>(_ query: Query) -> Future<K> {
        return Future<K> { resolver in
          
            guard let query = validate(query) else {
                resolver.set(CoreError.QueryNotSupported())
                return
            }
          
            query
                .request(url: self.url, session: self.session)
                .validate()
                .response { response in
            
                    guard response.error == nil else {
                        if let error = response.error as NSError? {
                            resolver.set(error)
                        }
                        return
                    }
            
                    do {
                        guard let data = response.data else { throw CoreError.DataSerialization() }
                        resolver.set(try self.decoder.decode(K.self, from: data))
                    } catch let error as NSError {
                        resolver.set(error)
                    }
                }
        }
    }

    @discardableResult
    fileprivate func validate(_ query: Query) -> NetworkQuery? {
        guard let query = query as? NetworkQuery else { _ = CoreError.QueryNotSupported("GetNetworkDataSource only supports NetworkQuery")
            return nil
        }
        
        guard query.method == NetworkQuery.Method.get else { _ = CoreError.QueryNotSupported("NetworkQuery method is \(query.method) instead of GET")
            return nil
        }

        return query
    }
}

open class PutNetworkDataSource<T: Codable>: PutDataSource {
    
    private let url: String
    private let session: Session
    private let decoder: JSONDecoder
    
    public init(url: String, session: Session, decoder: JSONDecoder) {
        self.url = url
        self.session = session
        self.decoder = decoder
    }

    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return Future { resolver in
            resolver.set(CoreError.QueryNotSupported())
        }
    }

    public func put(_ value: T?, in query: Query) -> Future<T> {
        return Future { resolver in
            
            guard let networkQuery = validate(query) else {
                resolver.set(CoreError.QueryNotSupported())
                return
            }
            
            let sanitizedNetworkQuery = try networkQuery.sanitizeContentType(value: value)
            
            sanitizedNetworkQuery
                .request(url: self.url, session: self.session)
                .validate()
                .response { response in
                    guard response.error == nil else {
                        if let error = response.error as NSError? {
                            resolver.set(error)
                        }
                        return
                    }

                    guard let data = response.data else {
                        resolver.set(CoreError.DataSerialization())
                        return
                    }
                    
                    do {
                        resolver.set(try self.decoder.decode(T.self, from: data))
                    } catch {
                        resolver.set(CoreError.DataSerialization())
                    }
                }
        }
    }
    
    private func validate(_ query: Query) -> NetworkQuery? {
        guard let networkQuery = query as? NetworkQuery else {
            return nil
        }

        switch networkQuery.method {
        case .put, .post: break
        default: return nil
        }
                
        return networkQuery
    }
    
}

fileprivate extension NetworkQuery {
    func sanitizeContentType<T: Encodable>(value: T?) throws -> NetworkQuery {
        let contentType = method.contentType()
        
        if contentType != nil && value != nil {
            throw CoreError.IllegalArgument("Conflicting arguments to be used as request body")
        }
        
        // Updating query if value is passed as separated argument from the query
        if (contentType == nil && value != nil) {
            method = method.with(contentType: NetworkQuery.ContentType.Json(entity: value))
        }
        
        return self
    }
}

open class DeleteNetworkDataSource: DeleteDataSource {

    private let url: String
    private let session: Session
    private let decoder: JSONDecoder

    public init(url: String, session: Session, decoder: JSONDecoder) {
        self.url = url
        self.session = session
        self.decoder = decoder
    }

    @discardableResult
    public func deleteAll(_ query: Query) -> Future<Void> {
        return execute(query)
    }

    @discardableResult
    public func delete(_ query: Query) -> Future<Void> {
        return execute(query)
    }
       
    private func execute(_ query: Query) -> Future<Void> {
        return Future { resolver in
          
            guard let query = validate(query) else {
                resolver.set(CoreError.QueryNotSupported())
                return
            }
          
            query
                .request(url: self.url, session: self.session).validate()
                .response { response in
            
                    guard response.error == nil else {
                        if let error = response.error as NSError? {
                            resolver.set(error)
                        }
                        return
                    }
            
                    do {
                        guard let _ = response.data else { throw CoreError.DataSerialization() }
                        resolver.set(())
                    } catch let error as NSError {
                        resolver.set(error)
                    }
                }
        }
    }

    @discardableResult
    fileprivate func validate(_ query: Query) -> NetworkQuery? {
        guard let query = query as? NetworkQuery else { _ = CoreError.QueryNotSupported("DeleteNetworkDataSource only supports NetworkQuery")
            return nil
        }
        
        guard query.method == NetworkQuery.Method.delete else { _ = CoreError.QueryNotSupported("NetworkQuery method is \(query.method) instead of DELETE")
            return nil
        }

        return query
    }
}


    
