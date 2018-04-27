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
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

///
/// Object acting as a key value observer
///
public class KeyValueObserver<V> : NSObject where V : Any {
    
    private lazy var context = "com.mobilejazz.\(String(describing: self)).\(self.keyPath)"
    
    private let resolver : FutureResolver<V>
    private var keyPath : String
    private var target : NSObject
    
    /// Convenience init method to use a closure
    ///
    /// - Parameters:
    ///   - target: The object to observe
    ///   - keyPath: The keyPath to observe
    ///   - closure: The callback closure
    public convenience init(target: NSObject, keyPath: String, _ closure: @escaping (V) -> Void ) {
        let future = Future<V>(reactive: true)
        future.then { closure($0) }
        self.init(target: target, keyPath: keyPath, resolver: FutureResolver(future))
    }
    
    /// Main init method to use a reactive future resolver as callback
    ///
    /// - Parameters:
    ///   - target: The object to observe
    ///   - keyPath: The keyPath to observe
    ///   - closure: The callback closure
    public init(target: NSObject, keyPath: String, resolver: FutureResolver<V>) {
        self.keyPath = keyPath
        self.target = target
        self.resolver = resolver
        super.init()
        self.target.addObserver(self, forKeyPath: keyPath, options: .new, context: &context)
    }
    
    deinit {
        self.target.removeObserver(self, forKeyPath: keyPath)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.context, let path = keyPath, path == self.keyPath {
            if let value = change?[NSKeyValueChangeKey.newKey] {
                resolver.set(value as! V)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
