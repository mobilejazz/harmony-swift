//
//  AsyncAnyPutRepository.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

///
/// A type eraser for the PutRepository type, following Apple's Swift Standard Library approach.
///
@available(iOS 13.0.0, *)
public final class AsyncAnyPutRepository <T> : AsyncPutRepository {
    
    private let box: AsyncPutRepositoryBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - repository: The repository to abstract
    public init<R: AsyncPutRepository>(_ repository: R) where R.T == T {
        box = AsyncPutRepositoryBox(repository)
    }
    
    public func put(_ value: T?, in query: Query, operation: Operation) async throws -> T {
        try await box.put(value, in: query, operation: operation)
    }
    
    public func putAll(_ array: [T], in query: Query, operation: Operation) async throws -> [T] {
        try await box.putAll(array, in: query, operation: operation)
    }
}

///
/// This is an abstract class. Do not use it.
/// PutRepository base class defining a generic type T (which is unrelated to the associated type of the PutRepository protocol)
///
@available(iOS 13.0.0, *)
internal class AsyncPutRepositoryBoxBase <T>: AsyncPutRepository {
    
    func put(_ value: T?, in query: Query, operation: Operation) async throws -> T {
        fatalError("This method is abstract.")
    }
    
    func putAll(_ array: [T], in query: Query, operation: Operation) async throws -> [T] {
        fatalError("This method is abstract.")
    }
}

///
/// A repository box, which has as generic type a PutRepository and links the PutRepositoryBoxBase type T as the Base.T type.
///
@available(iOS 13.0.0, *)
internal class AsyncPutRepositoryBox <Base: AsyncPutRepository> : AsyncPutRepositoryBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func put(_ value: T?, in query: Query, operation: Operation) async throws -> T {
        try await base.put(value, in: query, operation: operation)
    }
    
    override func putAll(_ array: [T], in query: Query, operation: Operation) async throws -> [T] {
        try await base.putAll(array, in: query, operation: operation)
    }
}
