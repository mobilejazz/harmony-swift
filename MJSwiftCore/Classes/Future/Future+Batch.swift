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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implOied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// Creates a new future from all given futures
public func batch<T>(_ futures : Future<T> ...) -> Future<[T]> {
    let reactive = futures.filter { $0.reactive }.count > 0
    let future = Future<[T]>(reactive:reactive)
    var dict : [Int:T] = [:]
    for (idx, futureT) in futures.enumerated() {
        futureT.then(success: { value in
            dict[idx] = value
            if future.result == nil || future.reactive {
                if dict.count == futures.count {
                    var array : [T] = []
                    for idx in 0..<dict.count {
                        array.append(dict[idx]!)
                    }
                    future.set(array)
                }
            }
        }, failure: { error in
            if future.result == nil || future.reactive {
                future.set(error)
            }
        })
    }
    return future
}

/// Creates a new future zipping the giving futures
public func zip<T,K>(_ futureT: Future<T>, _ futureK: Future<K>) -> Future<(T,K)> {
    return futureT.zip(futureK)
}

/// Creates a new future zipping the giving futures
public func zip<T,K,L>(_ futureT: Future<T>, _ futureK: Future<K>, _ futureL: Future<L>) -> Future<(T,K,L)> {
    return futureT.zip(futureK, futureL)
}

/// Creates a new future zipping the giving futures
public func zip<T,K,L,M>(_ futureT: Future<T>, _ futureK: Future<K>, _ futureL: Future<L>, _ futureM: Future<M>) -> Future<(T,K,L,M)> {
    return futureT.zip(futureK, futureL, futureM)
}

public extension Future {
    
    /// Creates a new future that holds the tupple of results
    public func zip<K>(_ futureK: Future<K>) -> Future<(T,K)> {
        return flatMap { valueT in
            return futureK.map { valueK in
                return (valueT, valueK)
            }
        }
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K,L>(_ futureK: Future<K>, _ futureL: Future<L>) -> Future<(T,K,L)> {
        return zip(futureK).flatMap { valueTK in
            return futureL.map { valueL in
                return (valueTK.0, valueTK.1, valueL)
            }
        }
    }
    
    /// Creates a new future that holds the tupple of results
    public func zip<K,L,M>(_ futureK: Future<K>, _ futureL: Future<L>, _ futureM: Future<M>) -> Future<(T,K,L,M)> {
        return zip(futureK, futureL).flatMap { valueTKL in
            return futureM.map { valueM in
                return (valueTKL.0, valueTKL.1, valueTKL.2, valueM)
            }
        }
    }
    
    /// Unzips a 2-tuple future into two futures
    public func unzip<K,L>() -> (Future<K>,Future<L>) where T == (K,L) {
        let futureK = Future<K>(reactive: reactive)
        let futureL = Future<L>(reactive: reactive)
        futureK.nestingLevel += nestingLevel
        futureL.nestingLevel += nestingLevel
        then(success: { tuple in
            futureK.set(tuple.0)
            futureL.set(tuple.1)
        }, failure: { error in
            futureK.set(error)
            futureL.set(error)
        })
        return (futureK, futureL)
    }
    
    /// Unzips a 3-tuple future into three futures
    public func unzip<K,L,M>() -> (Future<K>,Future<L>,Future<M>) where T == (K,L,M) {
        let futureK = Future<K>(reactive: reactive)
        let futureL = Future<L>(reactive: reactive)
        let futureM = Future<M>(reactive: reactive)
        futureK.nestingLevel += nestingLevel
        futureL.nestingLevel += nestingLevel
        futureM.nestingLevel += nestingLevel
        then(success: { tuple in
            futureK.set(tuple.0)
            futureL.set(tuple.1)
            futureM.set(tuple.2)
        }, failure: { error in
            futureK.set(error)
            futureL.set(error)
            futureM.set(error)
        })
        return (futureK, futureL, futureM)
    }
    
    /// Unzips a 4-tuple future into four futures
    public func unzip<K,L,M,N>() -> (Future<K>,Future<L>,Future<M>,Future<N>) where T == (K,L,M,N) {
        let futureK = Future<K>(reactive: reactive)
        let futureL = Future<L>(reactive: reactive)
        let futureM = Future<M>(reactive: reactive)
        let futureN = Future<N>(reactive: reactive)
        futureK.nestingLevel += nestingLevel
        futureL.nestingLevel += nestingLevel
        futureM.nestingLevel += nestingLevel
        futureN.nestingLevel += nestingLevel
        then(success: { tuple in
            futureK.set(tuple.0)
            futureL.set(tuple.1)
            futureM.set(tuple.2)
            futureN.set(tuple.3)
        }, failure: { error in
            futureK.set(error)
            futureL.set(error)
            futureM.set(error)
            futureN.set(error)
        })
        return (futureK, futureL, futureM, futureN)
    }
    
    /// Collapses a 2-tuple future into a single value future
    public func collapse<K,L,Z>(_ closure: @escaping (K,L) -> Z) -> Future<Z> where T == (K,L) {
        return Future<Z>(reactive: reactive) { future in
            future.nestingLevel = nestingLevel + 1
            then(success: { tuple in
                future.set(closure(tuple.0, tuple.1))
            }, failure: { error in
                future.set(error)
            })
        }
    }
    
    /// Collapses a 3-tuple future into a single value future
    public func collapse<K,L,M,Z>(_ closure: @escaping (K,L,M) -> Z) -> Future<Z> where T == (K,L,M) {
        return Future<Z>(reactive: reactive) { future in
            future.nestingLevel = nestingLevel + 1
            then(success: { tuple in
                future.set(closure(tuple.0, tuple.1, tuple.2))
            }, failure: { error in
                future.set(error)
            })
        }
    }
    
    /// Collapses a 4-tuple future into a single value future
    public func collapse<K,L,M,N,Z>(_ closure: @escaping (K,L,M,N) -> Z) -> Future<Z> where T == (K,L,M,N) {
        return Future<Z>(reactive: reactive) { future in
            future.nestingLevel = nestingLevel + 1
            then(success: { tuple in
                future.set(closure(tuple.0, tuple.1, tuple.2, tuple.3))
            }, failure: { error in
                future.set(error)
            })
        }
    }
}
