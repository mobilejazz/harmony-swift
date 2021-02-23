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

public protocol LinkRecognizerObserver : AnyObject {
    func linkRecognizer(_ linkRecognizer: LinkRecognizer, didRecognizeURLForKey key: String, components: [String])
    func linkRecognizer(_ linkRecognizer: LinkRecognizer, didFailToRecognizeURL url: URL, result: LinkRecognizer.Result)
}

public protocol LinkRecognizerDelegate : AnyObject {
    func linkRecognizer(_ linkRecognizer: LinkRecognizer, willRecognizeURLForKey key: String, components: [String]) -> Bool
}

public class LinkRecognizer {

    public enum Result : CustomStringConvertible {
        case valid([String])
        case unknownScheme
        case unsupportedLink
        
        public var description: String {
            get {
                switch (self) {
                case .valid(let components):
                    return "Valid with components: \(components)"
                case .unknownScheme:
                    return "UnkonwnScheme"
                case .unsupportedLink:
                    return "UnsupportedLink"
                }
            }
        }
    }
    
    public struct Pattern {
        public static let numeric = "(\\d+)"
        public static let nonNumeric = "(\\D+)"
        public static let alphanumeric = "(\\w+)"
        public static let alphanumericAndDash = "([\\w,-]+)"
    }

    public struct Options : OptionSet {
        public var rawValue: Int
        public typealias RawValue = Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public static let none             = Options([])
        public static let anchoredStart    = Options(rawValue: 1 << 0)
        public static let anchoredEnd      = Options(rawValue: 1 << 1)
        public static let caseInsensitive  = Options(rawValue: 1 << 2)
    }
    
    public weak var delegate : LinkRecognizerDelegate?
    
    private let scheme : String
    private var patterns : [String : String] = [:]
    private let options : Options
    private let observers = NSHashTable<AnyObject>.weakObjects()
    
    public init(scheme: String, options: Options = .none) {
        self.scheme = scheme
        self.options = options
    }
    
    public func registerPattern(_ pattern : String, forKey key: String) {
        patterns[key] = pattern
    }
    
    public func recognize(_ link: URL) -> Result {
        guard let scheme = link.scheme else {
            return Result.unknownScheme
        }
        
        if scheme != self.scheme {
            return Result.unknownScheme
        }
        
        guard let linkStr = (link as NSURL).resourceSpecifier else {
            return Result.unsupportedLink
        }
        
        let regexOptions = options.contains(.caseInsensitive) ? NSRegularExpression.Options.caseInsensitive : NSRegularExpression.Options(rawValue: 0)
        
        for (key, pattern) in patterns {
            var patternStr = pattern
            if options.contains(.caseInsensitive) {
                patternStr = "^\(patternStr)"
            }
            if options.contains(.anchoredEnd) {
                patternStr = "\(patternStr)$"
            }
            
            do {
                let regex = try NSRegularExpression(pattern: patternStr, options: regexOptions)
                if let result = regex.firstMatch(in: linkStr,
                                                 options: NSRegularExpression.MatchingOptions(rawValue:0),
                                                 range: NSMakeRange(0, linkStr.count)) {
                    var captures : [String] = []
                    for index in 0..<result.numberOfRanges {
                        if let range = Range(result.range(at: index), in: linkStr) {
                            let capture = linkStr[range]
                            captures.append(String(capture))
                        }
                    }
                
                    var canRecognizePattern = true
                
                    if let delegate = delegate {
                        canRecognizePattern = delegate.linkRecognizer(self, willRecognizeURLForKey: key, components: captures)
                 }
                
                    if canRecognizePattern {
                      for observer in observers.allObjects {
                            (observer as! LinkRecognizerObserver).linkRecognizer(self, didRecognizeURLForKey: key, components: captures)
                        }
                        return .valid(captures)
                    }
                }
            } catch (let error) {
                NSLog("\(error)")
            }
        }

        return .unsupportedLink
    }
    
    public func addObserver(_ observer: LinkRecognizerObserver) {
        observers.add(observer as AnyObject)
    }
    
    public func removeObserver(_ observer: LinkRecognizerObserver) {
        observers.remove(observer as AnyObject)
    }
}
