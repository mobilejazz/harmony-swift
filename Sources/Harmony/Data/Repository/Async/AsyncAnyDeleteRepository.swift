//
//  AsyncAnyDeleteRepository.swift
//  Harmony
//
//  Created by Borja Arias Drake on 19.08.2022..
//

import Foundation

///
/// A type eraser for the DeleteRepository type, following Apple's Swift Standard Library approach.
///
@available(iOS 13.0.0, *)
public final class AsyncAnyDeleteRepository: AsyncDeleteRepository {
    
    private let box: AsyncDeleteRepositoryBoxBase
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - repository: The repository to abstract
    public init<R: AsyncDeleteRepository>(_ repository: R) {
        box = AsyncDeleteRepositoryBox(repository)
    }
    
    public func delete(_ query: Query, operation: Operation) async throws {
        try await box.delete(query, operation: operation)
    }
    
    public func deleteAll(_ query: Query, operation: Operation) async throws {
        try await box.deleteAll(query, operation: operation)
    }
}

///
/// This is an abstract class. Do not use it.
/// DeleteRepository base class defining a generic type T (which is unrelated to the associated type of the DeleteRepository protocol)
///
@available(iOS 13.0.0, *)
internal class AsyncDeleteRepositoryBoxBase: AsyncDeleteRepository {
    func delete(_ query: Query, operation: Operation) async throws {
        fatalError("This method is abstract.")
    }
    
    func deleteAll(_ query: Query, operation: Operation) async throws {
        fatalError("This method is abstract.")
    }
}

///
/// A repository box, which has as generic type a DeleteRepository and links the DeleteRepositoryBoxBase type T as the Base.T type.
///
@available(iOS 13.0.0, *)
internal class AsyncDeleteRepositoryBox <Base: AsyncDeleteRepository> : AsyncDeleteRepositoryBoxBase {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func delete(_ query: Query, operation: Operation) async throws {
        try await base.delete(query, operation: operation)
    }
    
    override func deleteAll(_ query: Query, operation: Operation) async throws {
        try await base.deleteAll(query, operation: operation)
    }
}
