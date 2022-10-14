//
//  PutNetworkDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation
import Alamofire

public class PutNetworkDataSource<T: Codable>: PutDataSource {
    
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
                        if T.self == NoResponse.self {
                            resolver.set(NoResponse() as! T)
                        } else {
                            resolver.set(try self.decoder.decode(T.self, from: data))
                        }
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
