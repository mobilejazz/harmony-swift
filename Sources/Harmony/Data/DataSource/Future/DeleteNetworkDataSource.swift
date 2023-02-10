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

            let request = try url.toURLRequest(query: query)
            session.dataTask(with: request) { data, response, responseError in
                validateResponse(response: response, responseData: data, responseError: responseError) { _ in
                    resolver.set(())
                } failedValidation: { validationError in
                    resolver.set(validationError)
                }
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
