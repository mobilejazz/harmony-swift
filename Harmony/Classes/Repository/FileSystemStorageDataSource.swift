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
public class FileSystemStorageDataSource : GetDataSource, PutDataSource, DeleteDataSource {
    public typealias T = Data
    
    public enum FileNameEncoding {
        case none
        case sha256
        case md5
        case custom((String) -> String)
    }
    
    private let fileManager : FileManager
    public let directory : URL
    public let fileNameEncoding: FileNameEncoding
    private let writingOptions: Data.WritingOptions

    /// Main initializer
    ///
    /// - Parameters:
    ///   - fileManager: The FileManager
    ///   - directory: The directory where to store data
    public init(fileManager: FileManager, directory: URL, writingOptions: Data.WritingOptions = [], fileNameEncoding: FileNameEncoding = .sha256) {
        self.fileManager = fileManager
        self.directory = directory
        self.writingOptions = writingOptions
        self.fileNameEncoding = fileNameEncoding
    }
    
    /// Convenience initializer. Returns nil if the document directory is not reachable.
    ///
    /// - Parameters:
    ///   - relativePath: The relative path (example: "MyFolder/MySubfolder"), that will be appended on the documents directory
    public convenience init?(fileManager: FileManager, relativePath: String, writingOptions: Data.WritingOptions = [], fileNameEncoding: FileNameEncoding = .sha256) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = documentsURL.appendingPathComponent(relativePath)
        print(url);
        self.init(fileManager: fileManager, directory: url, writingOptions: writingOptions, fileNameEncoding: fileNameEncoding)
    }
    
    private func fileName(_ key: String) -> String {
        switch fileNameEncoding {
        case .none:
            return key
        case .sha256:
            return key.sha256()
        case .md5:
            return key.md5()
        case .custom(let encoder):
            return encoder(key)
        }
    }
    
    private func fileURL(_ key: String) -> URL {
        return directory.appendingPathComponent(fileName(key))
    }
    
    public func get(_ query: Query) -> Future<Data> {
        switch query {
        case let query as KeyQuery:
            let path = fileURL(query.key).path
            guard let data = fileManager.contents(atPath: path) else {
                return Future(CoreError.NotFound("Data not found at path: \(path)"))
            }
            return Future(data)
        default:
            query.fatalError(.get, self)
        }
    }
    
    public func getAll(_ query: Query) -> Future<[Data]> {
        switch query {
        case let query as IdsQuery<String>:
            let futures : [Future<Data>] = query.ids.map { id in
                let path = fileURL(id).path
                guard let data = fileManager.contents(atPath: path) else {
                    return Future(CoreError.NotFound("Data not found at path: \(path)"))
                }
                return Future(data)
            }
            return Future.batch(futures)
        case is AllObjectsQuery:
            return Future { r in
                var array: [Data] = []
                try fileManager
                    .contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey])
                    .filter { url in
                        // Filter out folders
                        do { return !(try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory! }
                        catch { return false }
                    }.forEach { url in
                    guard let data = fileManager.contents(atPath: url.path) else {
                        throw CoreError.NotFound("Data not found at path: \(url.path)")
                    }
                    // Attempting to unarchive in case it was an array
                    if let datas = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Data] {
                        // it was an array!
                        array.append(contentsOf: datas)
                    } else {
                        // Not an array!
                        array.append(data)
                    }
                }
                r.set(array)
            }
        case let query as KeyQuery:
            let path = fileURL(query.key).path
            guard let data = fileManager.contents(atPath: path) else {
                return Future(CoreError.NotFound("Data not found at path: \(path)"))
            }
            guard let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Data] else {
                return Future(CoreError.NotFound("Data not found at path: \(path)"))
            }
            return Future(array)
        default:
            query.fatalError(.getAll, self)
        }
    }
    
    public func put(_ value: Data?, in query: Query) -> Future<Data> {
        guard let data = value else {
            return Future(CoreError.IllegalArgument("value cannot be nil"))
        }
        guard let keyQuery = query as? KeyQuery else {
            query.fatalError(.put, self)
        }
        return Future { r in
            let fileURL = self.fileURL(keyQuery.key)
            let folderURL = fileURL.deletingLastPathComponent()
            if fileManager.fileExists(atPath: folderURL.path) == false {
                try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            try data.write(to: fileURL, options: writingOptions)
            r.set(data)
        }
    }
    
    public func putAll(_ array: [Data], in query: Query) -> Future<[Data]> {
        switch query {
        case let query as IdsQuery<String>:
            guard array.count == query.ids.count else {
                query.fatalError(.putAll, self)
            }
            return Future { r in
                try query.ids.enumerated().forEach { (offset, id) in
                    let fileURL = self.fileURL(id)
                    let folderURL = fileURL.deletingLastPathComponent()
                    if fileManager.fileExists(atPath: folderURL.path) == false {
                        try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                    }
                    try array[offset].write(to: fileURL, options: writingOptions)
                }
                r.set(array)
            }
        case let query as KeyQuery:
            return Future { r in
                let fileURL = self.fileURL(query.key)
                let folderURL = fileURL.deletingLastPathComponent()
                if fileManager.fileExists(atPath: folderURL.path) == false {
                    try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                }
                let data = NSKeyedArchiver.archivedData(withRootObject: array)
                try data.write(to: fileURL, options: writingOptions)
                r.set(array)
            }
        default:
            query.fatalError(.getAll, self)

        }
        
    }

    public func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let query as KeyQuery:
            return Future {
                try? fileManager.removeItem(at: fileURL(query.key))
            }
        default:
            query.fatalError(.delete, self)
        }
    }
    
    public func deleteAll(_ query: Query) -> Future<Void> {
        switch query {
        case let query as IdsQuery<String>:
            let futures : [Future<Void>] = query.ids.map { id in
                return Future {
                    try? fileManager.removeItem(at: fileURL(id))
                }
            }
            return Future.batch(futures).map { _ in Void() }
        case is AllObjectsQuery:
            return Future {
                
                // Deleting everything!
                try fileManager.removeItem(at: directory)
                
//                try fileManager
//                    .contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey])
//                    .filter { url in
//                        // Filter out folders
//                        do { return !(try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory! }
//                        catch { return false }
//                    }.forEach { url in
//                        try? fileManager.removeItem(at: url)
//                }
            }
        case let query as KeyQuery:
            return Future {
                try? fileManager.removeItem(at: fileURL(query.key))
            }
        default:
            query.fatalError(.deleteAll, self)
        }
    }
}
