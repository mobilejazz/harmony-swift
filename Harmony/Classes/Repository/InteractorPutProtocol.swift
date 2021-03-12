//
//  InteractorPutProtocol.swift
//  Harmony
//
//  Created by Borja Arias Drake on 12.03.2021..
//

import Foundation

public protocol PutByQueryInteractorProtocol {
    associatedtype T
    func execute(_ value: T?, query: Query, _ operation: Operation, in executor: Executor?) -> Future<T>
    func execute() -> Future<T>
    func execute<K>(_ value: T?, forId id: K, _ operation: Operation, in executor: Executor?) -> Future<T> where K:Hashable
    func execute<K>(_ value: T?, forId id: K) -> Future<T> where K:Hashable
}


///
/// A type eraser for the PutInteractor type, following Apple's Swift Standard Library approach.
///
public final class AnyPutByQueryInteractor <T> : PutByQueryInteractorProtocol {
    public typealias T = T
    
    
    private let box: AnyPutByQueryInteractorBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: PutByQueryInteractorProtocol>(_ interactor: R) where R.T == T {
        box = AnyPutByQueryInteractorBox(interactor)
    }
    
    public func execute(_ value: T?, query: Query, _ operation: Operation, in executor: Executor?) -> Future<T> {
        box.execute(value, query: query, operation, in: executor)
    }
    
    public func execute() -> Future<T> {
        box.execute(nil, query: VoidQuery(), DefaultOperation(), in: nil)
    }
    
    public func execute<K>(_ value: T?, forId id: K, _ operation: Operation, in executor: Executor?) -> Future<T> where K : Hashable {
        box.execute(value, forId: id, operation, in: executor)
    }
    
    public func execute<K>(_ value: T?, forId id: K) -> Future<T> where K : Hashable {
        box.execute(nil, forId: id, DefaultOperation(), in: nil)
    }
}

///
/// This is an abstract class. Do not use it.
/// PutInteractor base class defining a generic type T (which is unrelated to the associated type of the PutInteractor protocol)
///
internal class AnyPutByQueryInteractorBoxBase <T>: PutByQueryInteractorProtocol {
    
    typealias T = T
    
    func execute(_ value: T?, query: Query, _ operation: Operation, in executor: Executor?) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func execute() -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(_ value: T?, forId id: K, _ operation: Operation, in executor: Executor?) -> Future<T> where K : Hashable {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(_ value: T?, forId id: K) -> Future<T> where K : Hashable {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a PutInteractor and links the PutInteractorBoxBase type T as the Base.T type.
///
internal class AnyPutByQueryInteractorBox <Base: PutByQueryInteractorProtocol> : AnyPutByQueryInteractorBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ value: T?, query: Query, _ operation: Operation, in executor: Executor?) -> Future<T> {
        base.execute(value, query: query, operation, in: executor)
    }
    
    override func execute() -> Future<T> {
        base.execute(nil, query: VoidQuery(), DefaultOperation(), in: nil)
    }
    
    override func execute<K>(_ value: T?, forId id: K, _ operation: Operation, in executor: Executor?) -> Future<T> where K : Hashable {
        base.execute(value, forId: id, operation, in: executor)
    }
    
    override func execute<K>(_ value: T?, forId id: K) -> Future<T> where K : Hashable {
        base.execute(nil, forId: id, DefaultOperation(), in: nil)
    }
}

public protocol PutAllByQueryInteractorProtocol {
    associatedtype T
    func execute(_ array: [T], query: Query, _ operation: Operation, in executor: Executor?) -> Future<[T]>
    func execute() -> Future<[T]>
    func execute<K>(_ array: [T], forId id: K, _ operation: Operation, in executor: Executor?) -> Future<[T]> where K:Hashable
    func execute<K>(forId id: K) -> Future<[T]> where K:Hashable
}

///
/// A type eraser for the PutInteractor type, following Apple's Swift Standard Library approach.
///
public final class AnyPutAllByQueryInteractor <T> : PutAllByQueryInteractorProtocol {

    public typealias T = T
        
    private let box: AnyPutAllByQueryInteractorBoxBase<T>

    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: PutAllByQueryInteractorProtocol>(_ interactor: R) where R.T == T {
        box = AnyPutAllByQueryInteractorBox(interactor)
    }
    
    public func execute(_ array: [T], query: Query, _ operation: Operation, in executor: Executor?) -> Future<[T]> {
        box.execute(array, query: query, operation, in: executor)
    }
    
    public func execute() -> Future<[T]> {
        box.execute([], query: VoidQuery(), DefaultOperation(), in: nil)
    }
    
    public func execute<K>(_ array: [T], forId id: K, _ operation: Operation, in executor: Executor?) -> Future<[T]> where K : Hashable {
        box.execute(array, forId: id, operation, in: executor)
    }
    
    public func execute<K>(forId id: K) -> Future<[T]> where K : Hashable {
        box.execute([], forId: id, DefaultOperation(), in: nil)
    }
}

///
/// This is an abstract class. Do not use it.
/// PutInteractor base class defining a generic type T (which is unrelated to the associated type of the PutInteractor protocol)
///
internal class AnyPutAllByQueryInteractorBoxBase <T>: PutAllByQueryInteractorProtocol {
    
    typealias T = T
    
    func execute(_ array: [T], query: Query, _ operation: Operation, in executor: Executor?) -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func execute() -> Future<[T]> {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(_ array: [T], forId id: K, _ operation: Operation, in executor: Executor?) -> Future<[T]> where K : Hashable {
        fatalError("This method is abstract.")
    }
    
    func execute<K>(forId id: K) -> Future<[T]> where K : Hashable {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a PutInteractor and links the PutInteractorBoxBase type T as the Base.T type.
///
internal class AnyPutAllByQueryInteractorBox <Base: PutAllByQueryInteractorProtocol> : AnyPutAllByQueryInteractorBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ array: [T], query: Query, _ operation: Operation, in executor: Executor?) -> Future<[T]> {
        base.execute(array, query: query, operation, in: executor)
    }
    
    override func execute() -> Future<[T]> {
        base.execute([], query: VoidQuery(), DefaultOperation(), in: nil)
    }
    
    override func execute<K>(_ array: [T], forId id: K, _ operation: Operation, in executor: Executor?) -> Future<[T]> where K : Hashable {
        base.execute(array, forId: id, operation, in: executor)
    }
    
    override func execute<K>(forId id: K) -> Future<[T]> where K : Hashable {
        base.execute([], forId: id, DefaultOperation(), in: nil)
    }
}

public protocol PutInteractorProtocol {
    associatedtype T
    func execute(_ value: T?, _ operation: Operation, in executor: Executor?) -> Future<T>
    func execute() -> Future<T>
}

///
/// A type eraser for the PutInteractor type, following Apple's Swift Standard Library approach.
///
public final class AnyPutInteractor <T> : PutInteractorProtocol {
    
    public typealias T = T
        
    private let box: AnyPutInteractorBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: PutInteractorProtocol>(_ interactor: R) where R.T == T {
        box = AnyPutInteractorBox(interactor)
    }
    
    public func execute(_ value: T?, _ operation: Operation, in executor: Executor?) -> Future<T> {
        box.execute(value, operation, in: executor)
    }
    
    public func execute() -> Future<T> {
        box.execute(nil, DefaultOperation(), in: nil)
    }
}

///
/// This is an abstract class. Do not use it.
/// PutInteractor base class defining a generic type T (which is unrelated to the associated type of the PutInteractor protocol)
///
internal class AnyPutInteractorBoxBase <T>: PutInteractorProtocol {

    typealias T = T
    
    func execute(_ value: T?, _ operation: Operation, in executor: Executor?) -> Future<T> {
        fatalError("This method is abstract.")
    }
    
    func execute() -> Future<T> {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a PutInteractor and links the PutInteractorBoxBase type T as the Base.T type.
///
internal class AnyPutInteractorBox <Base: PutInteractorProtocol> : AnyPutInteractorBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ value: T?, _ operation: Operation, in executor: Executor?) -> Future<T> {
        base.execute(value, operation, in: executor)
    }
    
    override func execute() -> Future<T> {
        base.execute(nil, DefaultOperation(), in: nil)
    }
}

public protocol PutAllInteractorProtocol {
    associatedtype T
    func execute(_ array: [T], _ operation: Operation, in executor: Executor?) -> Future<[T]>
    func execute() -> Future<[T]>
}

///
/// A type eraser for the PutInteractor type, following Apple's Swift Standard Library approach.
///
public final class AnyPutAllInteractor <T> : PutAllInteractorProtocol {
        
    public typealias T = T
        
    private let box: AnyPutAllInteractorBoxBase<T>
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - interactor: The interactor to abstract
    public init<R: PutAllInteractorProtocol>(_ interactor: R) where R.T == T {
        box = AnyPutAllInteractorBox(interactor)
    }
    
    public func execute(_ array: [T], _ operation: Operation, in executor: Executor?) -> Future<[T]> {
        box.execute(array, operation, in: executor)
    }

    public func execute() -> Future<[T]> {
        box.execute([], DefaultOperation(), in: nil)
    }}

///
/// This is an abstract class. Do not use it.
/// PutInteractor base class defining a generic type T (which is unrelated to the associated type of the PutInteractor protocol)
///
internal class AnyPutAllInteractorBoxBase <T>: PutAllInteractorProtocol {
        
    typealias T = T
    
    func execute(_ array: [T], _ operation: Operation, in executor: Executor?) -> Future<[T]> {
        fatalError("This method is abstract.")
    }

    func execute() -> Future<[T]> {
        fatalError("This method is abstract.")
    }
}

///
/// A interactor box, which has as generic type a PutInteractor and links the PutInteractorBoxBase type T as the Base.T type.
///
internal class AnyPutAllInteractorBox <Base: PutAllInteractorProtocol> : AnyPutAllInteractorBoxBase <Base.T> {
    
    private let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override func execute(_ array: [T], _ operation: Operation, in executor: Executor?) -> Future<[T]> {
        base.execute(array, operation, in: executor)
    }

    override func execute() -> Future<[T]> {
        base.execute([], DefaultOperation(), in: nil)
    }
}
