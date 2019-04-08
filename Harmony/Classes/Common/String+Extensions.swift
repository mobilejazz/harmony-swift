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
import CommonCrypto

private let alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
                        "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                        "0","1","2","3","4","5","6","7","8","9"]

public extension String {
    
    /// Creates a random string of the given length.
    ///
    /// - Parameter length: The length of the string.
    init(randomOfLength length: UInt) {
        var string = ""
        for _ in 0..<length {
            let randomIndex = Int(arc4random() % UInt32(alphabet.count))
            string.append(alphabet[randomIndex])
        }
        self = string
    }
    
    /// Splits the string using the space character into an array of words.
    ///
    /// - Returns: An array of words.
    func words() -> [String] {
        return components(separatedBy: " ")
    }
    
    /// Returns the first word.
    ///
    /// - Returns: The first word.
    func firstWord() -> String {
        if let first = self.words().first {
            return first
        }
        return self
    }
    
    /// Returns the last word.
    ///
    /// - Returns: The last word.
    func lastWord() -> String {
        if let last = self.words().last {
            return last
        }
        return self
    }
    
    /// Removes the first word.
    ///
    /// - Returns: A string without the first word.
    func deleteFirstWord() -> String {
        let words = self.words()
        
        guard words.count > 0 else {
            return ""
        }
        
        let first = words.first!
        guard first.count + 1 < self.count  else {
            return ""
        }
        
        return replacingOccurrences(of: self,
                                    with: "",
                                    options: String.CompareOptions.anchored,
                                    range: Range(NSMakeRange(0, first.count + 1), in: self))
    }
    
    /// MD5 Hash
    ///
    /// - Returns: A MD5 Hashed string
    func md5() -> String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        #if swift(>=5.0)
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        #else
        _ = data.withUnsafeBytes { bytes in
            return CC_MD5(bytes, CC_LONG(data.count), &digest)
        }
        #endif
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
