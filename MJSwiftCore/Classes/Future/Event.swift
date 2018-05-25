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

///
/// Definition of an Event as a Observable of type Void.
///
public class Event : Observable<Void> {
    
    public override init(parent: Any? = nil) {
        super.init(parent: parent)
    }
    
    /// Trigger the event without any parameter
    public func trigger() {
        self.set()
    }
    
    @discardableResult
    public override func then(_ success: @escaping () -> Void) -> Observable<Void> {
        // If observable is reactive, clearing the current stored Void()
        self.clear()
        return super.then(success)
    }
    
    @discardableResult
    public override func fail(_ failure: @escaping (Error) -> Void) -> Observable<Void> {
        // If observable is reactive, clearing the current stored Void()
        self.clear()
        return super.fail(failure)
    }
}
