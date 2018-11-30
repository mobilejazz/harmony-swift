//
// Copyright 2018 Mobile Jazz SL
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
import FirebaseFirestore
import MJSwiftCore

extension FirebaseFirestore.Query {
    public func get(source: FirestoreSource = .default) -> Future<QuerySnapshot> {
        return Future { resolver in
            self.getDocuments(source: source) { (documents, error) in
                if let error = error {
                    resolver.set(error)
                } else {
                    resolver.set(documents!)
                }
            }
        }
    }
    
    public func observe(includeMetadataChanges: Bool = false) -> Observable<QuerySnapshot> {
        return Observable { resolver in
            let listener = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (documents, error) in
                if let error = error {
                    resolver.set(error)
                } else {
                    resolver.set(documents!)
                }
            }
            resolver.onDeinit {
                listener.remove()
            }
        }
    }
}

extension DocumentReference {
    public func get(source: FirestoreSource = .default) -> Future<DocumentSnapshot> {
        return Future { resolver in
            getDocument(source: source) { (document, error) in
                if let error = error {
                    resolver.set(error)
                } else {
                    resolver.set(document!)
                }
            }
        }
    }
    
    public func observe(includeMetadataChanges: Bool = false) -> Observable<DocumentSnapshot> {
        return Observable { resolver in
            let listener = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (document, error) in
                if let error = error {
                    resolver.set(error)
                } else {
                    resolver.set(document!)
                }
            }
            resolver.onDeinit {
                listener.remove()
            }
        }
    }
    
    public func put(data: [String : Any], merge : Bool = true) -> Future<Void> {
        return Future { resolver in
            setData(data, merge: merge) { error in
                if let error = error {
                    resolver.set(error)
                } else {
                    resolver.set()
                }
            }
        }
    }
    
    public func delete() -> Future<Void> {
        return Future { resolver in
            delete { error in
                if let error = error {
                    resolver.set(error)
                } else {
                    resolver.set()
                }
            }
        }
    }
}


extension CollectionReference {
    public func put(data: [String : Any]) -> Future<Void> {
        return Future { resolver in
            addDocument(data: data) { error in
                if let error = error {
                    resolver.set(error)
                } else {
                    resolver.set()
                }
            }
        }
    }
}
