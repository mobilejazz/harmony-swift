//
//  DeleteNetworkDataSource.swift
//  Harmony
//
//  Created by Borja Arias Drake on 11.10.2022..
//

import Foundation
import Alamofire

public class DeleteNetworkDataSource: DeleteDataSource {

    private let url: URL
    private let session: Session
    private let decoder: JSONDecoder

    public init(url: URL, session: Session, decoder: JSONDecoder) {
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
    private func validate(_ query: Query) -> NetworkQuery? {
        guard let query = query as? NetworkQuery else { _ = CoreError.QueryNotSupported("DeleteNetworkDataSource only supports NetworkQuery")
            return nil
        }
        
        guard query.method == NetworkQuery.Method.delete else { _ = CoreError.QueryNotSupported("NetworkQuery method is \(query.method) instead of DELETE")
            return nil
        }

        return query
    }
}

