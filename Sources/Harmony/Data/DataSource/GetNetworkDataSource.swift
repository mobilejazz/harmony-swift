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

import Foundation

public class GetNetworkDataSource<T: Decodable>: GetDataSource {
    
    private let url: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(url: URL, session: URLSession, decoder: JSONDecoder) {
        self.url = url
        self.session = session
        self.decoder = decoder
    }
    
    open func get(_ query: Query) -> Future<T> {
        return execute(query)
    }

    open func getAll(_ query: Query) -> Future<[T]> {
        return execute(query)
    }
        
    private func execute<K: Decodable>(_ query: Query) -> Future<K> {        
        return Future<K> { resolver in
            guard let query = getNetworkQuery(query) else {
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
                do {
                    resolver.set(try self.decoder.decode(K.self, from: data))
                } catch {
                    resolver.set(CoreError.DataSerialization())
                }
            }
            .resume()            
        }
    }

    @discardableResult
    private func getNetworkQuery(_ query: Query) -> NetworkQuery? {
        guard let query = query as? NetworkQuery else {
            return nil
        }
        
        guard query.method == NetworkQuery.Method.get else {
            return nil
        }

        return query
    }
}
