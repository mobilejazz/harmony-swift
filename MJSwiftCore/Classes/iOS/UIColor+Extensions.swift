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

import UIKit

private let AlphaMask : UInt32  = 0xFF000000
private let RedMask : UInt32    = 0xFF0000
private let GreenMask : UInt32  = 0xFF00
private let BlueMask : UInt32   = 0xFF

private let AlphaShift : UInt32 = 24
private let RedShift : UInt32   = 16
private let GreenShift : UInt32 = 8
private let BlueShift : UInt32  = 0

private let ColorSize : CGFloat = 256.0

private let RedLum : CGFloat    = 0.2989
private let GreenLum : CGFloat  = 0.5870
private let BlueLum : CGFloat   = 0.1140

public extension UIColor {

    public convenience init(rgbHexValue value: UInt32) {
        let red = (CGFloat)((value & RedMask) >> RedShift)
        let green = (CGFloat)((value & GreenMask) >> GreenShift)
        let blue = (CGFloat)((value & BlueMask) >> BlueShift)
        self.init(red: red/ColorSize, green: green/ColorSize, blue: blue/ColorSize, alpha: 1.0)
    }
    
    public convenience init(rgbaHexValue value: UInt32) {
        let red = (CGFloat)((value & RedMask) >> RedShift)
        let green = (CGFloat)((value & GreenMask) >> GreenShift)
        let blue = (CGFloat)((value & BlueMask) >> BlueShift)
        let alpha = (CGFloat)((value & AlphaShift) >> AlphaShift)
        self.init(red: red/ColorSize, green: green/ColorSize, blue: blue/ColorSize, alpha: alpha/ColorSize)
    }
    
    public convenience init(rgbHexString string: String) {
        var value : UInt32 = 0
        let scanner = Scanner(string: string)
        if scanner.scanHexInt32(&value) {
            self.init(rgbHexValue: value)
        } else {
            fatalError("Invalid RGB string value \(string)")
        }
    }
    
    public convenience init(rgbaHexString string: String) {
        var value : UInt32 = 0
        let scanner = Scanner(string: string)
        if scanner.scanHexInt32(&value) {
            self.init(rgbaHexValue: value)
        } else {
            fatalError("Invalid RGB string value \(string)")
        }
    }
    
    public convenience init(red255: CGFloat, blue255: CGFloat, green255: CGFloat) {
        self.init(red: red255/ColorSize, green: blue255/ColorSize, blue: green255/ColorSize, alpha: 1.0)
    }
    
    public convenience init(red255: CGFloat, blue255: CGFloat, green255: CGFloat, alpha255: CGFloat) {
        self.init(red: red255/ColorSize, green: blue255/ColorSize, blue: green255/ColorSize, alpha: alpha255/ColorSize)
    }
    
    public var rgbHexValue : UInt32 {
        get {
            if let components = self.cgColor.components {
                let count = self.cgColor.numberOfComponents
                if count == 4 {
                    let red = (UInt32)(round(components[0] * ColorSize))
                    let green = (UInt32)(round(components[1] * ColorSize))
                    let blue = (UInt32)(round(components[2] * ColorSize))
                    return (red << RedShift) + (green << GreenShift) + (blue << BlueShift)
                } else if count == 2 {
                    let gray = (UInt32)(round(components[0] * ColorSize))
                    return (gray << RedShift) + (gray << GreenShift) + (gray << BlueShift)
                }
            }
            return 0
        }
    }
    
    public var rgbaHexValue : UInt32 {
        get {
            if let components = self.cgColor.components {
                let count = self.cgColor.numberOfComponents
                if count == 4 {
                    let red = (UInt32)(round(components[0] * ColorSize))
                    let green = (UInt32)(round(components[1] * ColorSize))
                    let blue = (UInt32)(round(components[2] * ColorSize))
                    let alpha = (UInt32)(round(components[3] * ColorSize))
                    return (red << RedShift) + (green << GreenShift) + (blue << BlueShift) + (alpha << AlphaShift)
                } else if count == 2 {
                    let gray = (UInt32)(round(components[0] * ColorSize))
                    let alpha = (UInt32)(round(components[1] * ColorSize))
                    return (gray << RedShift) + (gray << GreenShift) + (gray << BlueShift) + (alpha << AlphaShift)
                }
            }
            return 0
        }
    }
    
    public var rgbHexString : String {
        get {
            let value = rgbHexValue
            return String(format:"%2X", value)
        }
    }
    
    public var rgbaHexString : String {
        get {
            let value = rgbaHexValue
            return String(format:"%2X", value)
        }
    }
    
    public func toGray() -> UIColor {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            if count == 4 {
                let luminiscence = components[0]*RedLum + components[1]*GreenLum + components[2]*BlueLum
                return UIColor(white:luminiscence, alpha:components[3])
            } else if count == 2 {
                return self
            }
        }
        return UIColor.gray
    }
    
    public func withSaturation(saturation: CGFloat) -> UIColor {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: saturation, brightness: b, alpha: a)
    }
    
    public func withBrightness(brightness: CGFloat) -> UIColor {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: brightness, alpha: a)
    }
    
    public func lighter(ratio: CGFloat) -> UIColor {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            
            let colorTransform : (CGFloat) -> CGFloat = { (component) in
                return component + (1.0 - component)*ratio
            }
            
            if count == 4 {
                let newComponents : [CGFloat] = [
                    colorTransform(components[0]),
                    colorTransform(components[1]),
                    colorTransform(components[2]),
                    components[3],
                ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: newComponents)!)
            } else if count == 2 {
                let newComponents : [CGFloat] = [
                    colorTransform(components[0]),
                    components[1],
                    ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceGray(), components: newComponents)!)
            }
        }
        return self
    }
    
    public func darker(ratio: CGFloat) -> UIColor {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            
            let colorTransform : (CGFloat) -> CGFloat = { (component) in
                return component * (1.0 - ratio)
            }
            
            if count == 4 {
                let newComponents : [CGFloat] = [
                    colorTransform(components[0]),
                    colorTransform(components[1]),
                    colorTransform(components[2]),
                    components[3],
                    ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: newComponents)!)
            } else if count == 2 {
                let newComponents : [CGFloat] = [
                    colorTransform(components[0]),
                    components[1],
                    ]
                return UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceGray(), components: newComponents)!)
            }
        }
        return self
    }
    
    public func isLightColor() -> Bool {
        if let components = self.cgColor.components {
            let count = self.cgColor.numberOfComponents
            if count == 4 {
                let luminiscence = components[0]*RedLum + components[1]*GreenLum + components[2]*BlueLum
                return luminiscence > 0.8
            } else if count == 2 {
                return components[0] > 0.8
            }
        }
        return false
    }
    
    public func isDarkColor() -> Bool {
        return !isLightColor()
    }
}
