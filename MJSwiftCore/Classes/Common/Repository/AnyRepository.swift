//
//  AnyRepository.swift
//  MJSwiftCore
//
//  Created by Borja Arias Drake on 20/06/2018.
//

import Foundation

/// A type eraser for the Repository type, following Apple's Swift Standard Library approach.
public class AnyRepository<T> : Repository {
    
    private var box: RepositoryBoxBase<T>
    
    init<R: Repository>(base: R) where R.T == T {
        self.box = RepositoryBox(base: base)
    }
    
    public func get(_ query: Query, operation: Operation) -> Future<T> {
        return self.box.get(query, operation: operation)
    }
    
    public func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        return self.box.getAll(query, operation: operation)
    }
    
    public func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return self.box.put(value, in: query, operation: operation)
    }
    
    public func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return self.box.putAll(array, in: query, operation: operation)
    }
    
    public func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return self.box.delete(query, operation: operation)
    }
    
    public func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return self.box.deleteAll(query, operation: operation)
    }
}

fileprivate class RepositoryBoxBase<T>: Repository {
    
    func get(_ query: Query, operation: Operation) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func delete(_ query: Query, operation: Operation) -> Future<Void> {
        fatalError("This method is abstract.")
    }
    
    func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        fatalError("This method is abstract.")
    }
}

fileprivate class RepositoryBox<Base : Repository> : RepositoryBoxBase<Base.T> {
    
    private var base: Base
    
    init(base: Base) {
        self.base = base
    }
    
    override func get(_ query: Query, operation: Operation) -> Future<T> {
        return self.base.get(query, operation: operation)
    }
    
    override func getAll(_ query: Query, operation: Operation) -> Future<[T]> {
        return self.base.getAll(query, operation: operation)
    }
    
    override func put(_ value: T?, in query: Query, operation: Operation) -> Future<T> {
        return self.base.put(value, in: query, operation: operation)
    }
    
    override func putAll(_ array: [T], in query: Query, operation: Operation) -> Future<[T]> {
        return self.base.putAll(array, in: query, operation: operation)
    }
    
    override func delete(_ query: Query, operation: Operation) -> Future<Void> {
        return self.base.delete(query, operation: operation)
    }
    
    override func deleteAll(_ query: Query, operation: Operation) -> Future<Void> {
        return self.base.deleteAll(query, operation: operation)
    }
}



