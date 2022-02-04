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
import CommonCrypto

extension Data {

    /// Creates random data of the given length.
    ///
    /// - Parameter length: The length of the data.
    public init?(randomOfLength length: UInt) {
        var bytes = [UInt8](repeating: 0, count: Int(length))
        let status = SecRandomCopyBytes(kSecRandomDefault, Int(length), &bytes)
        if status == errSecSuccess {
            self.init(bytes)
        } else {
            return nil
        }
    }
    
    /// HexEncoding options
    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue : Int) {
            self.rawValue = rawValue
        }
        
        public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    /// Returns the hexadecimal representation of the data.
    ///
    /// - Parameter options: Use .upperCase if needed.
    /// - Returns: The hexadecimal string representation.
    public func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    
    public init?(hexEncoded string: String) {
        // Get the UTF8 characters of this string
        let chars = Array(string.utf8)
        
        if chars.count % 2 != 0 {
            // Length of string must be even
            return nil
        }
        
        // Keep the bytes in an UInt8 array and later convert it to Data
        var bytes = [UInt8]()
        bytes.reserveCapacity(string.count / 2)
        
        // It is a lot faster to use a lookup map instead of strtoul
        let map: [UInt8] = [
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
            0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
            0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
        ]
        
        // Grab two characters at a time, map them and turn it into a byte
        for i in stride(from: 0, to: string.count, by: 2) {
            let char1 = chars[i]
            let char2 = chars[i+1]
            
            // ASCII validation
            guard (48 /* 0 */<= char1 && char1 <= 57 /* 9 */) ||
                (65 /* a */<= char1 && char1 <= 70 /* f */) ||
                (97 /* A */ <= char1 && char1 <= 102 /* F */) else {
                    return nil
            }
            
            guard (48 /* 0 */<= char2 && char2 <= 57 /* 9 */) ||
                (65 /* a */<= char2 && char2 <= 70 /* f */) ||
                (97 /* A */ <= char2 && char2 <= 102 /* F */) else {
                    return nil
            }
            
            let index1 = Int(char1 & 0x1F ^ 0x10)
            let index2 = Int(char2 & 0x1F ^ 0x10)
            bytes.append(map[index1] << 4 | map[index2])
        }
        
        self.init(bytes)
    }

    public func sha256() -> String {
        return digest().hexEncodedString()
    }
    
    private func digest() -> Data {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256((self as NSData).bytes, UInt32(self.count), &hash)
        return NSData(bytes: hash, length: digestLength) as Data
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

public extension String {
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}
