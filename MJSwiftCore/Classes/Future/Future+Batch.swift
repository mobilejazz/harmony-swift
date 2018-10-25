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

extension Future {
    
    /// Creates a new future from a sequence of futures.
    ///
    /// - Parameter futures: A sequence of futures.
    /// - Returns: The future batch.
    public static func batch(_ futures : Future<T> ...) -> Future<[T]> {
        return Future.batch(futures)
    }
    
    /// Creates a new future from an array of futures.
    ///
    /// - Parameter futures: An array of futures.
    /// - Returns: The future batch.
    public static func batch(_ futures : [Future<T>]) -> Future<[T]> {
        if futures.count == 0 {
            return Future<[T]>([])
        }
        
        let lock = NSLock()
        let future = Future<[T]>()
        var dict : [Int:T] = [:]
        for (idx, futureT) in futures.enumerated() {
            futureT.resolve(success: { value in
                lock.lock()
                dict[idx] = value
                if future.state != .sent {
                    if dict.count == futures.count {
                        var array : [T] = []
                        for idx in 0..<dict.count {
                            array.append(dict[idx]!)
                        }
                        future.set(array)
                    }
                }
                lock.unlock()
            }, failure: { error in
                lock.lock()
                future.set(error)
                lock.unlock()
            })
        }
        return future
    }
    
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
        let futureK = Future<K>()
        let futureL = Future<L>()
        resolve(success: {tuple in
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
        let futureK = Future<K>()
        let futureL = Future<L>()
        let futureM = Future<M>()
        resolve(success: {tuple in
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
        let futureK = Future<K>()
        let futureL = Future<L>()
        let futureM = Future<M>()
        let futureN = Future<N>()
        resolve(success: {tuple in
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
    public func collapse<K,L,Z>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K,L) -> Z) -> Future<Z> where T == (K,L) {
        return Future<Z>() { resolver in
            resolve(success: {tuple in
                executor.submit { resolver.set(closure(tuple.0, tuple.1)) }
            }, failure: { error in
                executor.submit { resolver.set(error) }
            })
        }
    }
    
    /// Collapses a 3-tuple future into a single value future
    public func collapse<K,L,M,Z>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K,L,M) -> Z) -> Future<Z> where T == (K,L,M) {
        return Future<Z>() { resolver in
            resolve(success: {tuple in
                executor.submit { resolver.set(closure(tuple.0, tuple.1, tuple.2)) }
            }, failure: { error in
                executor.submit { resolver.set(error) }
            })
        }
    }
    
    /// Collapses a 4-tuple future into a single value future
    public func collapse<K,L,M,N,Z>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K,L,M,N) -> Z) -> Future<Z> where T == (K,L,M,N) {
        return Future<Z>() { resolver in
            resolve(success: {tuple in
                executor.submit { resolver.set(closure(tuple.0, tuple.1, tuple.2, tuple.3)) }
            }, failure: { error in
                executor.submit { resolver.set(error) }
            })
        }
    }
}
