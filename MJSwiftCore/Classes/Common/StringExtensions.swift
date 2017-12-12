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

private let alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
                        "q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F",
                        "G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V",
                        "W","X","Z","Y","0","1","2","3","4","5","6","7","8","9"]

public extension String {
    
    public init(randomOfLength length: UInt) {
        
        var string = ""
        for _ in 0..<length {
            let randomIndex = Int(arc4random() % UInt32(alphabet.count))
            string.append(alphabet[randomIndex])
        }
        self = string
    }
    
    public func words() -> [String] {
        return components(separatedBy: " ")
    }
    
    public func firstWord() -> String {
        if let first = self.words().first {
            return first
        }
        return self
    }
    
    public func lastWord() -> String {
        if let last = self.words().last {
            return last
        }
        return self
    }
    
    public func deleteFirstWord() -> String {
        let words = self.words()
        if words.count > 0 {
            let first = words.first!
            if first.count + 1 < self.count {
                return replacingOccurrences(of: self,
                                            with: "",
                                            options: String.CompareOptions.anchored,
                                            range: Range(NSMakeRange(0, first.count + 1), in: self))
            }
        }
        return ""
    }
}
