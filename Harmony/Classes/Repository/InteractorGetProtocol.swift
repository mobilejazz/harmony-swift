//
//  InteractorGetProtocol.swift
//  Harmony
//
//  Created by Borja Arias Drake on 24.02.2021..
//

import Foundation

// MARK: - GetByQueryInteractorProtocol

public protocol GetByQueryInteractorProtocol {
    associatedtype M
    func execute(_ query: Query, _ operation: Operation, in executor: Executor?) -> Future<M>
    func execute() -> Future<M>
    func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<M> where K:Hashable
    func execute<K>(_ id: K) -> Future<M> where K:Hashable
}

///
/// A type eraser for the GetInteractor type, following Apple's Swift Standard Library approach.
///
public final class AnyGetByQueryInteractor <T> : GetByQueryInteractorProtocol {
    public typealias M = T
    
    
    private let box: AnyGetByQueryInteractorBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: GetByQueryInteractorProtocol>(_ interactor: R) where R.M == T {
        box = AnyGetByQueryInteractorBox(interactor)
    }
    
    public func execute(_ query: Query, _ operation: Operation, in executor: Executor?) -> Future<M> {
        return box.execute(query, operation, in: executor)
    }
    
    public func execute() -> Future<M> {
        return box.execute()
    }
    
    public func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<M> where K : Hashable {
        return box.execute(id, operation, in: executor)
    }
    
    public func execute<K>(_ id: K) -> Future<M> where K : Hashable {
        return box .execute(id)
    }
}

///
/// This is an abstract class. Do not use it.
/// GetInteractor base class defining a generic type T (which is unrelated to the associated type of the GetInteractor protocol)
///
internal class AnyGetByQueryInteractorBoxBase <T>: GetByQueryInteractorProtocol {
    typealias M = T
    
    func execute(_ query: Query, _ operation: Operation, in executor: Executor?) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func execute() -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<T> where K : Hashable {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(_ id: K) -> Future<T> where K : Hashable {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a GetInteractor and links the GetInteractorBoxBase type T as the Base.T type.
///
internal class AnyGetByQueryInteractorBox <Base: GetByQueryInteractorProtocol> : AnyGetByQueryInteractorBoxBase <Base.M> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ query: Query, _ operation: Operation, in executor: Executor?) -> Future<M> {
        return base.execute(query, operation, in: executor)
    }
    
    override func execute() -> Future<M> {
        return base.execute()
    }
    
    override func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<M> where K : Hashable {
        return base.execute(id, operation, in: executor)
    }
    
    override func execute<K>(_ id: K) -> Future<M> where K : Hashable {
        return base .execute(id)
    }
}

// MARK: - GetAllByQueryInteractorProtocol

public protocol GetAllByQueryInteractorProtocol {
    associatedtype M
    func execute(_ query: Query, _ operation: Operation , in executor: Executor?) -> Future<[M]>
    func execute() -> Future<[M]>
    func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<[M]> where K:Hashable
    func execute<K>(_ id: K) -> Future<[M]> where K:Hashable
}

public final class AnyGetAllByQueryInteractor <T> : GetAllByQueryInteractorProtocol {
    public typealias M = T
    
    
    private let box: AnyGetAllByQueryInteractorBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: GetAllByQueryInteractorProtocol>(_ interactor: R) where R.M == T {
        box = AnyGetAllByQueryInteractorBox(interactor)
    }
    
    public func execute(_ query: Query, _ operation: Operation, in executor: Executor?) -> Future<[M]> {
        return box.execute(query, operation, in: executor)
    }
    
    public func execute() -> Future<[M]> {
        return box.execute()
    }
    
    public func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<[M]> where K : Hashable {
        return box.execute(id, operation, in: executor)
    }
    
    public func execute<K>(_ id: K) -> Future<[M]> where K : Hashable {
        return box.execute(id)
    }
}

///
/// This is an abstract class. Do not use it.
/// GetInteractor base class defining a generic type T (which is unrelated to the associated type of the GetInteractor protocol)
///
internal class AnyGetAllByQueryInteractorBoxBase <T>: GetAllByQueryInteractorProtocol {
    
    typealias M = T
    
    func execute(_ query: Query, _ operation: Operation, in executor: Executor?) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func execute() -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<[T]> where K : Hashable {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(_ id: K) -> Future<[T]> where K : Hashable {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a GetInteractor and links the GetInteractorBoxBase type T as the Base.T type.
///
internal class AnyGetAllByQueryInteractorBox <Base: GetAllByQueryInteractorProtocol> : AnyGetAllByQueryInteractorBoxBase <Base.M> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ query: Query, _ operation: Operation, in executor: Executor?) -> Future<[M]> {
        return base.execute(query, operation, in: executor)
    }
    
    override func execute() -> Future<[M]> {
        return base.execute()
    }
    
    override func execute<K>(_ id: K, _ operation: Operation, in executor: Executor?) -> Future<[M]> where K : Hashable {
        return base.execute(id, operation, in: executor)
    }
    
    override func execute<K>(_ id: K) -> Future<[M]> where K : Hashable {
        return base .execute(id)
    }
}

// MARK: - GetInteractorProtocol

public protocol GetInteractorProtocol {
    associatedtype M
    func execute(_ operation: Operation, in executor: Executor?) -> Future<M>
    func execute() -> Future<M>
}

///
/// A type eraser for the GetInteractor type, following Apple's Swift Standard Library approach.
///
public final class AnyGetInteractor <T> : GetInteractorProtocol {
    public typealias M = T
    
    
    private let box: AnyGetInteractorBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: GetInteractorProtocol>(_ interactor: R) where R.M == T {
        box = AnyGetInteractorBox(interactor)
    }
    
    public func execute(_ operation: Operation, in executor: Executor?) -> Future<T> {
        return box.execute(operation, in: executor)
    }

    public func execute() -> Future<T> {
        return box.execute()
    }
}

///
/// This is an abstract class. Do not use it.
/// GetInteractor base class defining a generic type T (which is unrelated to the associated type of the GetInteractor protocol)
///
internal class AnyGetInteractorBoxBase <T>: GetInteractorProtocol {
        
    typealias M = T
    
    func execute(_ operation: Operation, in executor: Executor?) -> Future<T> {
        fatalError("This method is abstract.")
    }

    func execute() -> Future<T> {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a GetInteractor and links the GetInteractorBoxBase type T as the Base.T type.
///
internal class AnyGetInteractorBox <Base: GetInteractorProtocol> : AnyGetInteractorBoxBase <Base.M> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ operation: Operation, in executor: Executor?) -> Future<M> {
        return base.execute(operation, in: executor)
    }

    override func execute() -> Future<M> {
        return base.execute()
    }
}

// MARK: - GetAllInteractorProtocol

public protocol GetAllInteractorProtocol {
    associatedtype M
    func execute(_ operation: Operation, in executor: Executor?) -> Future<[M]>
    func execute() -> Future<[M]>
}

///
/// A type eraser for the GetInteractor type, following Apple's Swift Standard Library approach.
///
public final class AnyGetAllInteractor <T> : GetAllInteractorProtocol {
    public typealias M = T
    
    
    private let box: AnyGetAllInteractorBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: GetAllInteractorProtocol>(_ interactor: R) where R.M == T {
        box = AnyGetAllInteractorBox(interactor)
    }
    
    public func execute(_ operation: Operation, in executor: Executor?) -> Future<[T]> {
        return box.execute(operation, in: executor)
    }

    public func execute() -> Future<[T]> {
        return box.execute()
    }
}

///
/// This is an abstract class. Do not use it.
/// GetInteractor base class defining a generic type T (which is unrelated to the associated type of the GetInteractor protocol)
///
internal class AnyGetAllInteractorBoxBase <T>: GetAllInteractorProtocol {
        
    typealias M = T
    
    func execute(_ operation: Operation, in executor: Executor?) -> Future<[T]> {
        fatalError("This method is abstract.")
    }

    func execute() -> Future<[T]> {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a GetInteractor and links the GetInteractorBoxBase type T as the Base.T type.
///
internal class AnyGetAllInteractorBox <Base: GetAllInteractorProtocol> : AnyGetAllInteractorBoxBase <Base.M> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ operation: Operation, in executor: Executor?) -> Future<[M]> {
        return base.execute(operation, in: executor)
    }

    override func execute() -> Future<[M]> {
        return base.execute()
    }
}
