//
//  DeleteNetworkDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation

public class DeleteNetworkDataSource: DeleteDataSource {

    private let url: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(url: URL, session: URLSession, decoder: JSONDecoder) {
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
          
            guard let query = deleteNetworkQuery(query) else {
                resolver.set(CoreError.QueryNotSupported())
                return
            }
            
            let request = try query.request(url: url)
            session.dataTask(with: request) { data, response, responseError in
                guard let data = data else {
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
                resolver.set(())
            }
            .resume()
        }
    }

    @discardableResult
    private func deleteNetworkQuery(_ query: Query) -> NetworkQuery? {
        guard let query = query as? NetworkQuery else {
            return nil
        }
        
        guard query.method == NetworkQuery.Method.delete else {
            return nil
        }

        return query
    }
}

