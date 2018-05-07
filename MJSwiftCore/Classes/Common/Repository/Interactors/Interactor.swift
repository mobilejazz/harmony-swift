//
//  Interactor.swift
//  Alamofire
//
//  Created by Joan Martin on 04/05/2018.
//

import Foundation

// Namespace definition
public struct Interactor { }

///
/// Convenience superclass for interactors
///
open class QueryInteractor<T> {

    public let executor : Executor
    public let repository: Repository<T>
    
    public required init(_ executor: Executor, _ repository: Repository<T>) {
        self.executor = executor
        self.repository = repository
    }
}

///
/// Convenience superclass for interactors
///
open class DirectInteractor<T> : QueryInteractor <T>{
    public let query : Query
    
    @available(*, unavailable)
    public required init(_ executor: Executor, _ repository: Repository<T>) {
        self.query = BlankQuery()
        super.init(executor, repository)
    }
    
    public required init(_ executor: Executor, _ repository: Repository<T>, _ query: Query) {
        self.query = query
        super.init(executor, repository)
    }
    
    public convenience init<K>(_ executor: Executor, _ repository: Repository<T>, _ id: K) where K:Hashable {
        self.init(executor, repository, QueryById(id))
    }
}

