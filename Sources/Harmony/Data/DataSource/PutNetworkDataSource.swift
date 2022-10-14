//
//  PutNetworkDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation
import Alamofire


/// This class exists because Void is not Codable, and PutNetworkDataSource can receive NoResponse as the generic type parameter to indicate
/// that the server response's should not be parsed.
public struct NoResponse: Codable, Equatable {
    public init() {}
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}

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
            
            guard let networkQuery = validate(query) else {
                resolver.set(CoreError.QueryNotSupported())
                return
            }
            
            let sanitizedNetworkQuery = try networkQuery.sanitizeArrayContentType(value: array)
            
            sanitizedNetworkQuery
                .request(url: self.url, session: self.session)
                .validate()
                .response { response in
                    self.handleResponse(array, response: response, resolver: resolver)
                }
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
                    self.handleResponse(value, response: response, resolver: resolver)
                }
        }
    }

    private func handleResponse<K: Codable>(_ value: K?, response: AFDataResponse<Data?>, resolver: FutureResolver<K>) {
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
            if K.self == NoResponse.self {
                resolver.set(NoResponse() as! K)
            } else if K.self == [NoResponse].self {
                resolver.set([] as! K)
            } else {
                resolver.set(try self.decoder.decode(K.self, from: data))
            }
        } catch {
            resolver.set(CoreError.DataSerialization())
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
