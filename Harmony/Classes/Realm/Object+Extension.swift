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
import RealmSwift

public extension Object {
    static func find<T,K>(key: String, value: T, inRealm realm: Realm) -> K? where T: CVarArg, K:Object {
        let predicate = NSPredicate(format: "\(key) = %@", value)
        if let object = realm.objects(self).filter(predicate).first as? K {
            return object
        } else {
            return nil
        }
    }
    
    static func find<T,K>(keyedValues: [String : T], inRealm realm: Realm) -> K? where T: CVarArg, K:Object {
        var format = String()
        var args = Array<T>()
        var index = 0
        for (key, value) in keyedValues {
            format.append("\(key) = %@")
            args.append(value)
            
            if index < keyedValues.count - 1 {
                format.append(" AND ")
            }
            index += 1
        }
        
        let predicate = NSPredicate(format: format, argumentArray: args)
        if let object = realm.objects(self).filter(predicate).first as? K {
            return object
        } else {
            return nil
        }
    }
}
