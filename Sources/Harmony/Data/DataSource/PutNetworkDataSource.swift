//
//  PutNetworkDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation

/// This class exists because Void is not Codable, and PutNetworkDataSource can receive NoResponse as the generic type parameter to indicate
/// that the server response's should not be parsed.
public struct NoResponse: Codable, Equatable {
    public init() {}
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}

public class PutNetworkDataSource<T: Codable>: PutDataSource {
    
    private let url: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(url: URL, session: URLSession, decoder: JSONDecoder) {
        self.url = url
        self.session = session
        self.decoder = decoder
    }

    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return Future { resolver in
            
            guard let networkQuery = putNetworkQuery(query) else {
                resolver.set(CoreError.QueryNotSupported())
                return
            }
            
            let sanitizedNetworkQuery = try networkQuery.sanitizeArrayContentType(value: array)
            let request = try sanitizedNetworkQuery.request(url: url)
            session.dataTask(with: request) { data, response, responseError in
                self.handleResponse(array, response: response, responseData: data, responseError: responseError, resolver: resolver)
            }
            .resume()

        }
    }

    public func put(_ value: T?, in query: Query) -> Future<T> {
        return Future { resolver in
            
            guard let networkQuery = putNetworkQuery(query) else {
                resolver.set(CoreError.QueryNotSupported())
                return
            }
            
            let sanitizedNetworkQuery = try networkQuery.sanitizeContentType(value: value)
            let request = try sanitizedNetworkQuery.request(url: url)
            session.dataTask(with: request) { data, response, responseError in
                self.handleResponse(value, response: response, responseData: data, responseError: responseError, resolver: resolver)
            }
            .resume()
        }
    }

    private func handleResponse<K: Codable>(_ value: K?, response: URLResponse?, responseData: Data?, responseError: Error?, resolver: FutureResolver<K>) {
        guard let data = responseData else {
            resolver.set(CoreError.DataSerialization())
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            resolver.set(CoreError.Failed())
            return
        }
        guard responseError == nil else {
            resolver.set(responseError!)
            return
        }
        
        let statusCode = httpResponse.statusCode
        guard (200 ... 299) ~= statusCode else {
            resolver.set(CoreError.Failed("HTTP status code: \(statusCode)"))
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
    
    private func putNetworkQuery(_ query: Query) -> NetworkQuery? {
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
