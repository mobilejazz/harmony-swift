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

class GetNetworkDataSource<T: Decodable>: GetDataSource {
    
    @discardableResult
    func get(_ query: Query) -> Future<T> {
        return execute(validate(query))
    }
    
    @discardableResult
    func getAll(_ query: Query) -> Future<[T]> {
        return Future()
    }
    
    private func validate(_ query: Query) -> NetworkQuery? {
        guard query is NetworkQuery else { fatalError("Query is not a Network Query") }
        guard let query = query as? NetworkQuery else { fatalError("Query cast exception")}
        
        return query
    }
    
    fileprivate func resolve(_ resolver: FutureResolver<T> ,_ response: AFDataResponse<Data?>) {
        if response.error == nil {
            do {
                resolver.set(try JSONDecoder().decode(T.self, from: response.data!))
            } catch let error as NSError {
                resolver.set(error)
            }
        }
    }
    
    @discardableResult
    private func execute(_ query: NetworkQuery?) -> Future<T> {
        return Future { resolver in
            query?.buildRequest().response { [self] response in
                resolve(resolver, response)
            }
        }
    }
}
    
