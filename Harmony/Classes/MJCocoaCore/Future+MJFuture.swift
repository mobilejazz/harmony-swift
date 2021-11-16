//
// Copyright 2017 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import MJCocoaCore

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //
// MARK: -- Future to MJFuture --
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //

public extension Future where T : AnyObject {
    func toMJFuture() -> MJFuture<T> {
        let future = MJFuture<T>()
        resolve(success: {value in
            future.set(value)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == String {
    func toMJFuture() -> MJFuture<NSString> {
        let future = MJFuture<NSString>()
        resolve(success: {value in
            future.set(value as NSString)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == String? {
    func toMJFuture() -> MJFuture<NSString> {
        let future = MJFuture<NSString>()
        resolve(success: {value in
            future.set(value as NSString?)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Date {
    func toMJFuture() -> MJFuture<NSDate> {
        let future = MJFuture<NSDate>()
        resolve(success: {value in
            future.set(value as NSDate)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Date? {
    func toMJFuture() -> MJFuture<NSDate> {
        let future = MJFuture<NSDate>()
        resolve(success: {value in
            future.set(value as NSDate?)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == URL {
    func toMJFuture() -> MJFuture<NSURL> {
        let future = MJFuture<NSURL>()
        resolve(success: {value in
            future.set(value as NSURL)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == URL? {
    func toMJFuture() -> MJFuture<NSURL> {
        let future = MJFuture<NSURL>()
        resolve(success: {value in
            future.set(value as NSURL?)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Data {
    func toMJFuture() -> MJFuture<NSData> {
        let future = MJFuture<NSData>()
        resolve(success: {value in
            future.set(value as NSData)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Data? {
    func toMJFuture() -> MJFuture<NSData> {
        let future = MJFuture<NSData>()
        resolve(success: {value in
            future.set(value as NSData?)
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Bool {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        resolve(success: {value in
            future.set(NSNumber(value: value))
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Bool? {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        resolve(success: {value in
            if let value = value {
                future.set(NSNumber(value: value))
            } else {
                future.set(nil)
            }
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == UInt {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        resolve(success: {value in
            future.set(NSNumber(value: value))
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == UInt? {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        resolve(success: {value in
            if let value = value {
                future.set(NSNumber(value: value))
            } else {
                future.set(nil)
            }
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Int {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        self.resolve(success: {(value) in
            future.set(NSNumber(value: value))
        }, failure: { (error) in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Int? {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        resolve(success: {value in
            if let value = value {
                future.set(NSNumber(value: value))
            } else {
                future.set(nil)
            }
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Float {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        self.resolve(success: {(value) in
            future.set(NSNumber(value: value))
        }, failure: { (error) in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Float? {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        resolve(success: {value in
            if let value = value {
                future.set(NSNumber(value: value))
            } else {
                future.set(nil)
            }
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Double {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        self.resolve(success: {(value) in
            future.set(NSNumber(value: value))
        }, failure: { (error) in
            future.set(error)
        })
        return future
    }
}

public extension Future where T == Double? {
    func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>()
        resolve(success: {value in
            if let value = value {
                future.set(NSNumber(value: value))
            } else {
                future.set(nil)
            }
        }, failure: { error in
            future.set(error)
        })
        return future
    }
}

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //
// MARK: -- MJFuture to Future --
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- //

public extension Future {
    convenience init<K>(mjfuture: MJFuture<K>) where T==K? {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                resolver.set(value)
                }.fail { error in
                resolver.set(error)
            }
        }
    }
}

public extension Future where T == String? {
    convenience init(mjfuture: MJFuture<NSString>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                resolver.set(value as String?)
                }.fail { error in
                 resolver.set(error)
            }
        }
    }
}

public extension Future where T == Date? {
    convenience init(mjfuture: MJFuture<NSDate>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                resolver.set(value as Date?)
                }.fail { error in
                    resolver.set(error)
            }
        }
    }
}

public extension Future where T == URL? {
    convenience init(mjfuture: MJFuture<NSURL>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                resolver.set(value as URL?)
                }.fail { error in
                    resolver.set(error)
            }
        }
    }
}

public extension Future where T == Data? {
    convenience init(mjfuture: MJFuture<NSData>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                resolver.set(value as Data?)
                }.fail { error in
                    resolver.set(error)
            }
        }
    }
}

public extension Future where T == Bool? {
    convenience init(mjfuture: MJFuture<NSNumber>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                let value = value?.boolValue
                resolver.set(value)
                }.fail { error in
                    resolver.set(error)
            }
        }
    }
}

public extension Future where T == Int? {
    convenience init(mjfuture: MJFuture<NSNumber>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                let value = value?.intValue
                resolver.set(value)
                }.fail { error in
                    resolver.set(error)
            }
        }
    }
}

public extension Future where T == Float? {
    convenience init(mjfuture: MJFuture<NSNumber>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                let value = value?.floatValue
                resolver.set(value)
                }.fail { error in
                    resolver.set(error)
            }
        }
    }
}

public extension Future where T == Double? {
    convenience init(mjfuture: MJFuture<NSNumber>) {
        if mjfuture.reactive {
            fatalError("Can't link a reactive MJFuture<T> to a Future<T>. Use Observable<T> instead.")
        }
        self.init() { resolver in
            mjfuture.then { value in
                let value = value?.doubleValue
                resolver.set(value)
                }.fail { error in
                    resolver.set(error)
            }
        }
    }
}



// -- -- -- -- -- -- -- - -- -- -- -- -- //
// MARK: Extension on MJFuture
// -- -- -- -- -- -- -- - -- -- -- -- -- //

public extension MJFuture where T == NSString {
    func toFuture() -> Future<String?> {
        return Future(mjfuture:self)
    }
}

public extension MJFuture where T == NSURL {
    func toFuture() -> Future<URL?> {
        return Future(mjfuture:self)
    }
}

public extension MJFuture where T == NSDate {
    func toFuture() -> Future<Date?> {
        return Future(mjfuture:self)
    }
}

public extension MJFuture where T == NSData {
    func toFuture() -> Future<Data?> {
        return Future(mjfuture:self)
    }
}

