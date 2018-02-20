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

public extension Future where T : AnyObject {
    public func toMJFuture() -> MJFuture<T> {
        let future = MJFuture<T>(reactive: reactive)
        resolve(success: {value in
            future.setValue(value)
        }, failure: { error in
            future.setError(error)
        })
        return future
    }
}

public extension Future where T == String {
    public func toMJFuture() -> MJFuture<NSString> {
        let future = MJFuture<NSString>(reactive: reactive)
        resolve(success: {value in
            future.setValue(value as NSString)
        }, failure: { error in
            future.setError(error)
        })
        return future
    }
}

public extension Future where T == Bool {
    public func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>(reactive: reactive)
        resolve(success: {value in
            future.setValue(NSNumber(value: value))
        }, failure: { error in
            future.setError(error)
        })
        return future
    }
}

public extension Future where T == UInt {
    public func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>(reactive: reactive)
        resolve(success: {value in
            future.setValue(NSNumber(value: value))
        }, failure: { error in
            future.setError(error)
        })
        return future
    }
}

public extension Future where T == Int {
    public func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>(reactive: reactive)
        self.resolve(success: {(value) in
            future.setValue(NSNumber(value: value))
        }, failure: { (error) in
            future.setError(error)
        })
        return future
    }
}

public extension Future where T == Float {
    public func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>(reactive: reactive)
        self.resolve(success: {(value) in
            future.setValue(NSNumber(value: value))
        }, failure: { (error) in
            future.setError(error)
        })
        return future
    }
}

public extension Future where T == Double {
    public func toMJFuture() -> MJFuture<NSNumber> {
        let future = MJFuture<NSNumber>(reactive: reactive)
        self.resolve(success: {(value) in
            future.setValue(NSNumber(value: value))
        }, failure: { (error) in
            future.setError(error)
        })
        return future
    }
}
