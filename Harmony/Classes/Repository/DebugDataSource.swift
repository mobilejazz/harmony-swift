//
// Copyright 2019 Mobile Jazz SL
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

public enum DebugDataSourceDelay {
    case none
    case sync(TimeInterval)
    case async(TimeInterval, DispatchQueue)
}

public enum DebugDataSourceError {
    case none
    case error(Error, probability: Double)
    
    func fail() throws {
        switch self {
        case .none:
            break
        case .error(let error, let probability):
            if Double.random(in: 0.0...1.0) <= probability {
                throw error
            }
        }
    }
}

private class DebugDataSourceToken {
    
    let id : String = {
        let base = String(randomOfLength: 8)
        let seed = DispatchTime.now()
        return String("\(base)::\(seed.uptimeNanoseconds)".md5().suffix(8)).uppercased()
    }()
    
    private var startTime : DispatchTime?
    private var endTime : DispatchTime?
    
    func start() {
        startTime = DispatchTime.now()
    }
    
    func end() {
        endTime = DispatchTime.now()
    }
    
    func time() -> TimeInterval? {
        guard let start = startTime, let end = endTime else {
            return nil
        }
        let seconds = TimeInterval((end.uptimeNanoseconds - start.uptimeNanoseconds)) / 1_000_000_000
        return seconds
    }
}

public class DebugDataSource <D,T> : GetDataSource, PutDataSource, DeleteDataSource where D: GetDataSource, D:PutDataSource, D:DeleteDataSource, D.T == T {
    
    private let dataSource : D
    private let delay : DebugDataSourceDelay
    private let error : DebugDataSourceError
    private let logger : Logger
    
    public init(_ dataSource: D,
                delay: DebugDataSourceDelay = .none,
                error: DebugDataSourceError = .none,
                logger: Logger = DeviceConsoleLogger()) {
        self.dataSource = dataSource
        self.delay = delay
        self.error = error
        self.logger = logger
    }
    
    private func postprocess<K>(_ future: Future<K>, _ method: DataSourceCRUD, _ token: DebugDataSourceToken) -> Future<K> {
        return addError(addDelay(future.onCompletion { token.end() })).then { result in
            self.log(method, token, "Completed with result: \(String(describing: result))")
            }.fail{ error in
                self.log(method, token, "Failed with error: \(error)")
        }
    }
    
    private func addDelay<K>(_ future: Future<K>) -> Future<K> {
        switch delay {
        case .none:
            return future
        case .sync(let delay):
            return future.withBlockingDelay(delay)
        case .async(let delay, let queue):
            return future.withDelay(delay, queue: queue)
        }
    }
    
    private func addError<K>(_ future: Future<K>) -> Future<K> {
        return future.filter { _ in try self.error.fail() }
    }
    
    private func log(_ method: DataSourceCRUD, _ token: DebugDataSourceToken, _ message: String) {
        if let time = token.time() {
            logger.info(tag: String(describing: type(of: dataSource)), "[\(method).\(token.id) in <\(time)>s]: \(message)")
        } else {
            logger.info(tag: String(describing: type(of: dataSource)), "[\(method).\(token.id)]: \(message)")
        }
    }
    
    public func get(_ query: Query) -> Future<T> {
        let token = DebugDataSourceToken()
        log(.get, token, String(describing: query))
        token.start()
        return postprocess(dataSource.get(query), .get, token)
    }
    
    public func getAll(_ query: Query) -> Future<[T]> {
        let token = DebugDataSourceToken()
        log(.getAll, token, String(describing: query))
        token.start()
        return postprocess(dataSource.getAll(query), .getAll, token)
    }
    
    public func put(_ value: T?, in query: Query) -> Future<T> {
        let token = DebugDataSourceToken()
        log(.put, token, "\(String(describing: query)) - \(String(describing: value))")
        return postprocess(dataSource.put(value, in: query), .put, token)
    }
    
    public func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        let token = DebugDataSourceToken()
        log(.putAll, token, "\(String(describing: query)) - \(String(describing: array))")
        token.start()
        return postprocess(dataSource.putAll(array, in: query), .putAll, token)
    }
    
    public func delete(_ query: Query) -> Future<Void> {
        let token = DebugDataSourceToken()
        log(.delete, token, String(describing: query))
        token.start()
        return postprocess(dataSource.delete(query), .delete, token)
    }
    
    public func deleteAll(_ query: Query) -> Future<Void> {
        let token = DebugDataSourceToken()
        log(.deleteAll, token, String(describing: query))
        token.start()
        return postprocess(dataSource.deleteAll(query), .deleteAll, token)
    }
}
