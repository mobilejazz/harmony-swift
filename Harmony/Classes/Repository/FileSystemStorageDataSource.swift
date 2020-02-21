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

///
/// Reads and stores Data in files within a folder using IdQueries and KeyQuery as filename queries.
///
/// Example of usage:
///    - `get("my_file.dat").then { data in [...] }`
///    - `put(data, "data_file.dat").fail { error in [...] }`
///    - `delete("my_file.dat").fail { error in [...] }`
///
class FileSystemStorageDataSource : GetDataSource, PutDataSource, DeleteDataSource {
    typealias T = Data
    
    private let fileManager : FileManager
    private let directory : URL
    
    /// Main initializer
    ///
    /// - Parameters:
    ///   - fileManager: The FileManager
    ///   - directory: The directory where to store data
    init(fileManager: FileManager, directory: URL) {
        self.fileManager = fileManager
        self.directory = directory
    }
    
    /// Convenience initializer. Returns nil if the document directory is not reachable.
    ///
    /// - Parameters:
    ///   - fileManager: Teh FileManager
    ///   - relativePath: The relative path (example: "MyFolder/MySubfolder"), that will be appended on the documents directory
    convenience init?(fileManager: FileManager, relativePath: String) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        self.init(fileManager: fileManager, directory: documentsURL.appendingPathComponent(relativePath))
    }
    
    func get(_ query: Query) -> Future<Data> {
        switch query {
        case let query as KeyQuery:
            let path = directory.appendingPathComponent(query.key).path
            guard let data = fileManager.contents(atPath: path) else {
                return Future(CoreError.NotFound("Data not found at path: \(path)"))
            }
            return Future(data)
        default:
            query.fatalError(.get, self)
        }
    }
    
    func getAll(_ query: Query) -> Future<[Data]> {
        switch query {
        case let query as IdsQuery<String>:
            let futures : [Future<Data>] = query.ids.map { id in
                let path = directory.appendingPathComponent(id).path
                guard let data = fileManager.contents(atPath: path) else {
                    return Future(CoreError.NotFound("Data not found at path: \(path)"))
                }
                return Future(data)
            }
            return Future.batch(futures)
        case is AllObjectsQuery:
            return Future { r in
                let futures : [Future<Data>] = try fileManager
                    .contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey])
                    .filter { url in
                        // Filter out folders
                        do { return !(try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory! }
                        catch { return false }
                    }.map { url in
                    guard let data = fileManager.contents(atPath: url.path) else {
                        return Future(CoreError.NotFound("Data not found at path: \(url.path)"))
                    }
                    return Future(data)
                }
                r.set(Future.batch(futures))
            }
        default:
            query.fatalError(.getAll, self)
        }
    }
    
    func put(_ value: Data?, in query: Query) -> Future<Data> {
        guard let data = value else {
            return Future(CoreError.IllegalArgument("value cannot be nil"))
        }
        guard let keyQuery = query as? KeyQuery else {
            query.fatalError(.put, self)
        }
        return Future { r in
            let fileURL = directory.appendingPathComponent(keyQuery.key)
            let folderURL = fileURL.deletingLastPathComponent()
            if fileManager.fileExists(atPath: folderURL.path) == false {
                try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            try data.write(to: fileURL)
            r.set(data)
        }
    }
    
    func putAll(_ array: [Data], in query: Query) -> Future<[Data]> {
        guard let idsQuery = query as? IdsQuery<String> else {
            query.fatalError(.putAll, self)
        }
        guard array.count == idsQuery.ids.count else {
            query.fatalError(.putAll, self)
        }
        return Future { r in
            try idsQuery.ids.enumerated().forEach { (offset, id) in
                let fileURL = directory.appendingPathComponent(id)
                let folderURL = fileURL.deletingLastPathComponent()
                if fileManager.fileExists(atPath: folderURL.path) == false {
                    try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                }
                try array[offset].write(to: fileURL)
            }
            r.set(array)
        }
    }

    func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            return Future {
                try fileManager.removeItem(at: directory.appendingPathComponent(query.key))
            }
        default:
            query.fatalError(.delete, self)
        }
    }
    
    func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as IdsQuery<String>:
            let futures : [Future<Void>] = query.ids.map { id in
                return Future {
                    try fileManager.removeItem(at: directory.appendingPathComponent(id))
                }
            }
            return Future.batch(futures).map { _ in Void() }
        case is AllObjectsQuery:
            return Future {
                try fileManager
                    .contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey])
                    .filter { url in
                        // Filter out folders
                        do { return !(try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory! }
                        catch { return false }
                    }.forEach { url in
                        try fileManager.removeItem(at: url)
                }
            }
        default:
            query.fatalError(.deleteAll, self)
        }
    }
}
