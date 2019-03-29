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

public extension Observable {
    
    /// Creates a new observable from a sequence of observables.
    /// Note that the batch will be delivered once all observables have resolved at least once. After that, the batch will resolve on all new resolves. Each single error will be delivered independently.
    ///
    /// - Parameter futures: A sequence of observables.
    /// - Returns: The observable batch.
    static func batch(_ futures : Observable<T> ...) -> Observable<[T]> {
        return Observable.batch(futures)
    }
    
    /// Creates a new observable from an array of observables.
    /// Note that the batch will be delivered once all observables have resolved at least once. After that, the batch will resolve on all new resolves. Each single error will be delivered independently.
    ///
    /// - Parameter futures: An array of observables.
    /// - Returns: The observable batch.
    static func batch(_ futures : [Observable<T>]) -> Observable<[T]> {
        if futures.count == 0 {
            return Observable<[T]>([])
        }
        
        let lock = NSLock()
        let future = Observable<[T]>()
        var dict : [Int:T] = [:]
        for (idx, futureT) in futures.enumerated() {
            futureT.resolve(success: { value in
                lock.lock()
                dict[idx] = value
                if dict.count == futures.count {
                    var array : [T] = []
                    for idx in 0..<dict.count {
                        array.append(dict[idx]!)
                    }
                    future.set(array)
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
    
    /// Creates a new observable that holds the tupple of results
    func zip<K>(_ observableK: Observable<K>) -> Observable<(T,K)> {
        return flatMap { valueT in
            return observableK.map { valueK in
                return (valueT, valueK)
            }
        }
    }
    
    /// Creates a new observable that holds the tupple of results
    func zip<K,L>(_ observableK: Observable<K>, _ observableL: Observable<L>) -> Observable<(T,K,L)> {
        return zip(observableK).flatMap { valueTK in
            return observableL.map { valueL in
                return (valueTK.0, valueTK.1, valueL)
            }
        }
    }
    
    /// Creates a new observable that holds the tupple of results
    func zip<K,L,M>(_ observableK: Observable<K>, _ observableL: Observable<L>, _ observableM: Observable<M>) -> Observable<(T,K,L,M)> {
        return zip(observableK, observableL).flatMap { valueTKL in
            return observableM.map { valueM in
                return (valueTKL.0, valueTKL.1, valueTKL.2, valueM)
            }
        }
    }
    
    /// Unzips a 2-tuple observable into two observables
    func unzip<K,L>() -> (Observable<K>,Observable<L>) where T == (K,L) {
        let observableK = Observable<K>()
        let observableL = Observable<L>()
        resolve(success: {tuple in
            observableK.set(tuple.0)
            observableL.set(tuple.1)
        }, failure: { error in
            observableK.set(error)
            observableL.set(error)
        })
        return (observableK, observableL)
    }
    
    /// Unzips a 3-tuple observable into three observables
    func unzip<K,L,M>() -> (Observable<K>,Observable<L>,Observable<M>) where T == (K,L,M) {
        let observableK = Observable<K>()
        let observableL = Observable<L>()
        let observableM = Observable<M>()
        resolve(success: {tuple in
            observableK.set(tuple.0)
            observableL.set(tuple.1)
            observableM.set(tuple.2)
        }, failure: { error in
            observableK.set(error)
            observableL.set(error)
            observableM.set(error)
        })
        return (observableK, observableL, observableM)
    }
    
    /// Unzips a 4-tuple observable into four observables
    func unzip<K,L,M,N>() -> (Observable<K>,Observable<L>,Observable<M>,Observable<N>) where T == (K,L,M,N) {
        let observableK = Observable<K>()
        let observableL = Observable<L>()
        let observableM = Observable<M>()
        let observableN = Observable<N>()
        resolve(success: {tuple in
            observableK.set(tuple.0)
            observableL.set(tuple.1)
            observableM.set(tuple.2)
            observableN.set(tuple.3)
        }, failure: { error in
            observableK.set(error)
            observableL.set(error)
            observableM.set(error)
            observableN.set(error)
        })
        return (observableK, observableL, observableM, observableN)
    }
    
    /// Collapses a 2-tuple observable into a single value observable
    func collapse<K,L,Z>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K,L) -> Z) -> Observable<Z> where T == (K,L) {
        return Observable<Z>() { observable in
            resolve(success: {tuple in
                executor.submit { observable.set(closure(tuple.0, tuple.1)) }
            }, failure: { error in
                executor.submit { observable.set(error) }
            })
        }
    }
    
    /// Collapses a 3-tuple observable into a single value observable
    func collapse<K,L,M,Z>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K,L,M) -> Z) -> Observable<Z> where T == (K,L,M) {
        return Observable<Z>() { observable in
            resolve(success: {tuple in
                executor.submit { observable.set(closure(tuple.0, tuple.1, tuple.2)) }
            }, failure: { error in
                executor.submit { observable.set(error) }
            })
        }
    }
    
    /// Collapses a 4-tuple observable into a single value observable
    func collapse<K,L,M,N,Z>(_ executor: Executor = DirectExecutor(), _ closure: @escaping (K,L,M,N) -> Z) -> Observable<Z> where T == (K,L,M,N) {
        return Observable<Z>() { observable in
            resolve(success: {tuple in
                executor.submit { observable.set(closure(tuple.0, tuple.1, tuple.2, tuple.3)) }
            }, failure: { error in
                executor.submit { observable.set(error) }
            })
        }
    }
}
