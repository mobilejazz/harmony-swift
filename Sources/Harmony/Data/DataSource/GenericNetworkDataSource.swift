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
import Alamofire

open class GetNetworkDataSource<T: Decodable>: GetDataSource {

    private var url: String
    private var session: Session

    public init(url: String, session: Session) {
        self.url = url
        self.session = session
    }
    
    @discardableResult
    open func get(_ query: Query) -> Future<T> {
        
        return Future { resolver in
            guard let query = validate(query) else { return resolver.set(CoreError.QueryNotSupported()) }
            
            query.request(url: self.url, session: self.session).validate().response { response in
                guard response.error == nil else { return }
                
                do {
                    resolver.set(try self.decode(response))
                } catch let error as NSError {
                    resolver.set(error)
                }
            }
        }
    }
    
    @discardableResult
    open func getAll(_ query: Query) -> Future<[T]> {                        
        
        return Future { resolver in
            guard let query = validate(query) else { return resolver.set(CoreError.QueryNotSupported()) }
            
            query.request(url: self.url, session: self.session).validate().response { response in
                guard response.error == nil else { return }
                
                do {
                    resolver.set(try self.decode(response))
                } catch let error as NSError {
                    resolver.set(error)
                }
            }
        }
    }
    
    @discardableResult
    fileprivate func validate(_ query: Query) -> NetworkQuery? {
        
        guard let query = query as? NetworkQuery else { _ = CoreError.QueryNotSupported("Query cast exception")
            return nil
        }
        
        guard query.method == NetworkQuery.Method.get else { _ = CoreError.QueryNotSupported("Not get query")
            return nil
        }

        return query
    }
    
    fileprivate func decode(_ response: AFDataResponse<Data?>) throws -> [T] {
        guard let data = response.data else { throw CoreError.DecodingFailed() }
        return try JSONDecoder().decode([T].self, from: data)
    }
    
    fileprivate func decode(_ response: AFDataResponse<Data?>) throws -> T {
        guard let data = response.data else { throw CoreError.DecodingFailed() }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
    
