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

/// Creates a new observable from all given observables
public func batch<T>(_ observables : Observable<T> ...) -> Observable<[T]> {
    let observable = Observable<[T]>()
    var dict : [Int:T] = [:]
    for (idx, observableT) in observables.enumerated() {
        observableT.resolve(success: {value in
            dict[idx] = value
            if observable._result == nil {
                if dict.count == observables.count {
                    var array : [T] = []
                    for idx in 0..<dict.count {
                        array.append(dict[idx]!)
                    }
                    observable.set(array)
                }
            }
        }, failure: { error in
            if observable._result == nil {
                observable.set(error)
            }
        })
    }
    return observable
}

/// Creates a new observable zipping the giving observables
public func zip<T,K>(_ observableT: Observable<T>, _ observableK: Observable<K>) -> Observable<(T,K)> {
    return observableT.zip(observableK)
}

/// Creates a new observable zipping the giving observables
public func zip<T,K,L>(_ observableT: Observable<T>, _ observableK: Observable<K>, _ observableL: Observable<L>) -> Observable<(T,K,L)> {
    return observableT.zip(observableK, observableL)
}

/// Creates a new observable zipping the giving observables
public func zip<T,K,L,M>(_ observableT: Observable<T>, _ observableK: Observable<K>, _ observableL: Observable<L>, _ observableM: Observable<M>) -> Observable<(T,K,L,M)> {
    return observableT.zip(observableK, observableL, observableM)
}

public extension Observable {
    
    /// Creates a new observable that holds the tupple of results
    public func zip<K>(_ observableK: Observable<K>) -> Observable<(T,K)> {
        return flatMap { valueT in
            return observableK.map { valueK in
                return (valueT, valueK)
            }
        }
    }
    
    /// Creates a new observable that holds the tupple of results
    public func zip<K,L>(_ observableK: Observable<K>, _ observableL: Observable<L>) -> Observable<(T,K,L)> {
        return zip(observableK).flatMap { valueTK in
            return observableL.map { valueL in
                return (valueTK.0, valueTK.1, valueL)
            }
        }
    }
    
    /// Creates a new observable that holds the tupple of results
    public func zip<K,L,M>(_ observableK: Observable<K>, _ observableL: Observable<L>, _ observableM: Observable<M>) -> Observable<(T,K,L,M)> {
        return zip(observableK, observableL).flatMap { valueTKL in
            return observableM.map { valueM in
                return (valueTKL.0, valueTKL.1, valueTKL.2, valueM)
            }
        }
    }
    
    /// Unzips a 2-tuple observable into two observables
    public func unzip<K,L>() -> (Observable<K>,Observable<L>) where T == (K,L) {
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
    public func unzip<K,L,M>() -> (Observable<K>,Observable<L>,Observable<M>) where T == (K,L,M) {
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
    public func unzip<K,L,M,N>() -> (Observable<K>,Observable<L>,Observable<M>,Observable<N>) where T == (K,L,M,N) {
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
    public func collapse<K,L,Z>(_ closure: @escaping (K,L) -> Z) -> Observable<Z> where T == (K,L) {
        return Observable<Z>() { observable in
            resolve(success: {tuple in
                observable.set(closure(tuple.0, tuple.1))
            }, failure: { error in
                observable.set(error)
            })
        }
    }
    
    /// Collapses a 3-tuple observable into a single value observable
    public func collapse<K,L,M,Z>(_ closure: @escaping (K,L,M) -> Z) -> Observable<Z> where T == (K,L,M) {
        return Observable<Z>() { observable in
            resolve(success: {tuple in
                observable.set(closure(tuple.0, tuple.1, tuple.2))
            }, failure: { error in
                observable.set(error)
            })
        }
    }
    
    /// Collapses a 4-tuple observable into a single value observable
    public func collapse<K,L,M,N,Z>(_ closure: @escaping (K,L,M,N) -> Z) -> Observable<Z> where T == (K,L,M,N) {
        return Observable<Z>() { observable in
            resolve(success: {tuple in
                observable.set(closure(tuple.0, tuple.1, tuple.2, tuple.3))
            }, failure: { error in
                observable.set(error)
            })
        }
    }
}
