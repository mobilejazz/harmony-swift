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

public struct CornerInset {
    let topLeft : CGFloat
    let topRight : CGFloat
    let bottomLeft : CGFloat
    let bottomRight : CGFloat
    
    public init() {
        self.topLeft = 0
        self.topRight = 0
        self.bottomLeft = 0
        self.bottomRight = 0
    }
    
    public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    public init(radius: CGFloat) {
        self.init(topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius)
    }
}

extension CornerInset : Equatable, CustomStringConvertible {
    public static func == (lhs: CornerInset, rhs: CornerInset) -> Bool {
        return lhs.topLeft == rhs.topLeft &&
            lhs.topRight == rhs.topRight &&
            lhs.bottomLeft == rhs.bottomLeft &&
            lhs.bottomRight == rhs.bottomRight
    }
    
    public var description: String {
        get {
            return "{topLeft:\(topLeft), topRight:\(topRight), bottomLeft:\(bottomLeft), bottomRight:\(bottomRight)}"
        }
    }
}

/// The image tinting styles.
///
/// - keepingAlpha: Keep transaprent pixels (alpha == 0) and tint all other pixels.
/// - overAlpha: Keep non transparent pixels and tint only those that are translucid.
/// - overAlphaExtreme: Remove (turn to transparent) non transparent pixels and tint only those that are translucid.
public enum TintStyle {
    case keepingAlpha
    case overAlpha
    case overAlphaExtreme
}

extension TintStyle : CustomStringConvertible {
    public var description: String {
        get {
            switch self {
            case .keepingAlpha:
                return "keepingAlpha"
            case .overAlpha:
                return "overAlpha"
            case .overAlphaExtreme:
                return "overAlphaExtreme"
            }
        }
    }
}

/// Defines the gradient direction.
///
/// - vertical: Vertical direction
/// - horizontal: Horizontal direction
/// - leftSlanted: Left slanted direction.
/// - rightSlanted: Right slanted direction.
public enum GradientDirection {
    case vertical
    case horizontal
    case leftSlanted
    case rightSlanted
}

extension GradientDirection : CustomStringConvertible {
    public var description: String {
        get {
            switch self {
            case .vertical:
                return "vertical"
            case .horizontal:
                return "horizontal"
            case .leftSlanted:
                return "leftSlanted"
            case .rightSlanted:
                return "rightSlanted"
            }
        }
    }
}

public extension UIImage {
    
//    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerInset : CornerInset = CornerInset()) {
//        guard let image = UIImage.image(color: color, size: size, cornerInset: cornerInset) else {
//            return nil
//        }
//        self.init(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
//    }
    
    public static func image(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerInset : CornerInset = CornerInset()) -> UIImage? {
        let descriptors : [String:String] = [
            "resizable": "false",
            "color":"\(color.rgbaString)",
            "size":"\(size)",
            "cornerInset":"\(cornerInset)"
        ]
        
        if let image = UIImage.cachedWithDescriptors(descriptors) {
            return image
        } else {
            
            let scale = UIScreen.main.scale
            let rect = CGRect(x: 0, y: 0, width: scale*size.width, height: scale*size.height)
            let cornerInset = CornerInset(topLeft: cornerInset.topLeft*scale,
                                          topRight: cornerInset.topRight*scale,
                                          bottomLeft: cornerInset.bottomLeft*scale,
                                          bottomRight: cornerInset.bottomRight*scale)
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            if let context = CGContext(data: nil,
                                       width: (Int)(rect.size.width),
                                       height: (Int)(rect.size.height),
                                       bitsPerComponent: 8,
                                       bytesPerRow: 0,
                                       space: colorSpace,
                                       bitmapInfo:bitmapInfo.rawValue) {
                context.beginPath()
                context.setFillColor(gray: 1.0, alpha: 0.0)
                context.addRect(rect)
                context.closePath()
                context.drawPath(using: .fill)
                
                context.setFillColor(color.cgColor)
                context.beginPath()
                context.move(to: CGPoint(x: rect.minX, y: rect.midY))
                context.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.midX, y: rect.minY), radius: cornerInset.bottomLeft)
                context.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.midY), radius: cornerInset.bottomRight)
                context.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.midX, y: rect.maxY), radius: cornerInset.topRight)
                context.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.midY), radius: cornerInset.topLeft)
                context.closePath()
                context.drawPath(using: .fill)
                
                let image = UIImage(cgImage: context.makeImage()!, scale: scale, orientation: UIImageOrientation.up)
                image.cacheWithDescriptors(descriptors)
                return image
            } else {
                return nil
            }
        }
    }
    
    public static func resizable(color: UIColor, cornerInset : CornerInset = CornerInset()) -> UIImage? {
        
        let descriptors : [String:String] = [
            "resizable": "true",
            "color":"\(color.rgbaString)",
            "cornerInset":"\(cornerInset)"
        ]
        
        if let image = UIImage.cachedWithDescriptors(descriptors) {
            return image
        } else {
            let size = CGSize(width: max(cornerInset.topLeft, cornerInset.bottomLeft) + max(cornerInset.topRight, cornerInset.bottomRight) + 1,
                              height: max(cornerInset.topLeft, cornerInset.topRight) + max(cornerInset.bottomLeft, cornerInset.bottomRight) + 1)
            
            let insets = UIEdgeInsetsMake(max(cornerInset.topLeft, cornerInset.topRight),
                                          max(cornerInset.topLeft, cornerInset.bottomLeft),
                                          max(cornerInset.bottomLeft, cornerInset.bottomRight),
                                          max(cornerInset.topRight, cornerInset.bottomRight))
            
            guard let image = UIImage.image(color:color, size: size, cornerInset: cornerInset) else {
                return nil
            }
            
            let resizableImage = image.resizableImage(withCapInsets: insets)
            resizableImage.cacheWithDescriptors(descriptors)
            return resizableImage
        }
    }
    
    public static func resizable(color: UIColor, radius : CGFloat) -> UIImage?  {
        return UIImage.resizable(color: color, cornerInset: CornerInset(radius: radius))
    }
    
//    public convenience init?(named: String, tintColor: UIColor, style: TintStyle = .keepingAlpha) {
//        guard let image = UIImage.image(named: named, tintColor: tintColor, style: style) else {
//            return nil
//        }
//        self.init(cgImage: image.cgImage!)
//    }
    
    public static func image(named: String, tintColor: UIColor, style: TintStyle = .keepingAlpha) -> UIImage? {
        let descriptors : [String:String] = [
            "name": named,
            "tint.color":"\(tintColor.rgbaString)",
            "tint.style":"\(style)"
        ]
        
        if let image = UIImage.cachedWithDescriptors(descriptors) {
            return image
        } else {
            guard let image = UIImage(named:named) else {
                return nil
            }
            let tintedImage = image.tintedWithColor(tintColor, style: style)
            tintedImage.cacheWithDescriptors(descriptors)
            return image
        }
    }
    
    public func tintedWithColor(_ color: UIColor, style: TintStyle = .keepingAlpha) -> UIImage {
        let size = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let cgImage = self.cgImage!
        
        switch style {
        case .keepingAlpha:
            context.setBlendMode(.normal)
            context.draw(cgImage, in: rect)
            context.setBlendMode(.sourceIn)
            color.setFill()
            context.fill(rect)
        case .overAlpha:
            color.setFill()
            context.fill(rect)
            context.setBlendMode(.normal)
            context.draw(cgImage, in: rect)
        case .overAlphaExtreme:
            color.setFill()
            context.fill(rect)
            context.setBlendMode(.destinationOut)
            context.draw(cgImage, in: rect)
        }
        let image = UIImage(cgImage: context.makeImage()!, scale: self.scale, orientation: .up)
        UIGraphicsEndImageContext()
        return image
    }
    
    public func withCornerInset(_ cornerInset: CornerInset) -> UIImage {
        if !isValidCornerInset(cornerInset) {
            return self
        }
        
        let scale = self.scale
        let rect = CGRect(x: 0, y: 0, width: scale*size.width, height: scale*size.height)
        let cornerInset = CornerInset(topLeft: cornerInset.topLeft*scale,
                                      topRight: cornerInset.topRight*scale,
                                      bottomLeft: cornerInset.bottomLeft*scale,
                                      bottomRight: cornerInset.bottomRight*scale)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let context = CGContext(data: nil,
                                   width: (Int)(rect.size.width),
                                   height: (Int)(rect.size.height),
                                   bitsPerComponent: 8,
                                   bytesPerRow: 0,
                                   space: colorSpace,
                                   bitmapInfo:bitmapInfo.rawValue) {
            
            context.beginPath()
            context.move(to: CGPoint(x: rect.minX, y: rect.midY))
            context.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.midX, y: rect.minY), radius: cornerInset.bottomLeft)
            context.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.midY), radius: cornerInset.bottomRight)
            context.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.midX, y: rect.maxY), radius: cornerInset.topRight)
            context.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.midY), radius: cornerInset.topLeft)
            context.closePath()
            context.clip()
            context.draw(self.cgImage!, in: rect)
            
            let image = UIImage(cgImage: context.makeImage()!, scale: scale, orientation: .up)
            return image
        }
        return self
    }
    
    public func isValidCornerInset(_ cornerInset: CornerInset) -> Bool {
        if cornerInset.topLeft + cornerInset.topRight > self.size.width {
            return false
        } else if cornerInset.topRight + cornerInset.bottomRight > self.size.height {
            return false
        } else if cornerInset.bottomRight + cornerInset.bottomLeft > self.size.width {
            return false
        } else if cornerInset.bottomLeft + cornerInset.topLeft > self.size.height {
            return false
        }
        return true
    }
    
    public func addImage(_ image: UIImage, offset: CGPoint = CGPoint(x: 0, y: 0)) -> UIImage {
        let scale = self.scale
        let size = CGSize(width: self.size.width*scale, height: self.size.height*scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        image.draw(in: CGRect(x: scale*offset.x, y: scale*offset.y, width: scale*image.size.width, height: scale*image.size.height))
        let context = UIGraphicsGetCurrentContext()!
        let image = UIImage(cgImage: context.makeImage()!, scale: scale, orientation: UIImageOrientation.up)
        UIGraphicsEndImageContext()
        return image
    }
    
    public func resizeTo(size : CGSize, interpolationQuality: CGInterpolationQuality = .default) -> UIImage {
        let transform = resizeTransformationToSize(size)
        var drawTransposed = false
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        
        let cgImage = self.cgImage!
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral
        let transposedRect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        if let context = CGContext(data: nil,
                                   width: (Int)(rect.size.width),
                                   height: (Int)(rect.size.height),
                                   bitsPerComponent: cgImage.bitsPerComponent,
                                   bytesPerRow: 0,
                                   space: cgImage.colorSpace!,
                                   bitmapInfo: cgImage.bitmapInfo.rawValue) {
            context.concatenate(transform)
            context.interpolationQuality = interpolationQuality
            context.draw(cgImage, in: drawTransposed ? transposedRect : rect)
            let image = UIImage(cgImage: context.makeImage()!)
            return image
        }
        
        return self
    }
    
//    public convenience init?(gradientColors: [UIColor], size: CGSize, direction: GradientDirection) {
//        guard let image = UIImage.image(gradientColors: gradientColors, size: size, direction: direction) else {
//            return nil
//        }
//        self.init(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
//    }
    
    public static func image(gradientColors: [UIColor], size: CGSize, direction: GradientDirection) -> UIImage? {
        let descriptors : [String:String] = [
            "size" : "\(size)",
            "resizable" : "false",
            "gradient.colors" : "\(gradientColors.map({ c in c.rgbaValue }))",
            "gradient.direction" : "\(direction)"
        ]
        
        if let image = UIImage.cachedWithDescriptors(descriptors) {
            return image
        } else {
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors.map({ c in c.cgColor }) as CFArray, locations: nil) else { return nil }
            
            var startPoint = CGPoint.zero
            var endPoint = CGPoint.zero
            switch direction {
            case .vertical:
                endPoint.y = rect.size.height
            case .horizontal:
                endPoint.x = rect.size.width
            case .leftSlanted:
                endPoint = CGPoint(x: rect.size.width, y : rect.size.height)
            case .rightSlanted:
                startPoint.x = rect.size.width
                endPoint.y = rect.size.height
            }
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue:0))
            let cgImage = context.makeImage()!
            UIGraphicsEndImageContext()
            return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: UIImageOrientation.up)
        }
    }
    
    public static func resizable(gradientColors: [UIColor], size: CGSize, direction: GradientDirection) -> UIImage? {
        if (size.width == 0.0 && direction == .horizontal) ||
            (size.height == 0.0 && direction == .vertical) ||
            (size.height == 0.0 && size.width == 0.0) {
            return nil
        }
        
        let descriptors : [String : String] = [
            "size" : "\(size)",
            "resizable" : "true",
            "gradient.colors" : "\(gradientColors.map({ c in c.rgbaValue }))",
            "gradient.direction" : "\(direction)"
        ]

        if let image = UIImage.cachedWithDescriptors(descriptors) {
            return image
        } else {
            var imageSize = CGSize(width: 1, height: 1)
            var insets = UIEdgeInsets.zero
            
            switch direction {
            case .vertical:
                imageSize.height = size.height
                insets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
            case .horizontal:
                imageSize.width = size.width
                insets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
            default:
                imageSize = size
                insets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
                break;
            }
            
            if let image = UIImage.image(gradientColors: gradientColors, size: imageSize, direction: direction) {
                let resizableImage = image.resizableImage(withCapInsets: insets)
                resizableImage.cacheWithDescriptors(descriptors)
                return resizableImage
            } else {
                return nil
            }
        }
    }
}

let cache = NSCache<NSString, UIImage>()
let observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning,
                                                      object: nil,
                                                      queue: OperationQueue.main) { n in cache.removeAllObjects() }

extension UIImage {
    
    static func cachedWithDescriptors(_ descriptors: [String:String]) -> UIImage? {
        let key = cacheKeyWithDescriptors(descriptors)
        let image = cache.object(forKey: NSString(string:key))
        return image
    }
    
    func cacheWithDescriptors(_ descriptors: [String:String]) {
        let key = UIImage.cacheKeyWithDescriptors(descriptors)
        cache.setObject(self, forKey: NSString(string:key))
    }
    
    static func cacheKeyWithDescriptors(_ descriptors : [String:String]) -> String {
        var string : String = ""
        let keys = descriptors.keys.sorted()
        for key in keys {
            string.append("\(key):\(descriptors[key]!)")
        }
        return string
    }
    
    func resizeTransformationToSize(_ size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored: // EXIF 3,4
            transform = CGAffineTransform(translationX: size.width, y: size.height)
            transform = transform.rotated(by: (CGFloat)(Double.pi))
        case .left, .leftMirrored: // EXIF 6,5
            transform = CGAffineTransform(translationX: size.width, y: 0)
            transform = transform.rotated(by: (CGFloat)(Double.pi/2.0))
        case .right, .rightMirrored: // EXIF 8,7
            transform = CGAffineTransform(translationX: 0, y: size.height)
            transform = transform.rotated(by: (CGFloat)(-Double.pi/2.0))
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored: // EXIF 2,4
            transform = CGAffineTransform(translationX: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored: // EXIF 5,7
            transform = CGAffineTransform(translationX: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        return transform
    }
}

public extension UIImage {
    public static func black() -> UIImage { return UIImage.resizable(color:UIColor.black)! }
    public static func gray() -> UIImage { return UIImage.resizable(color:UIColor.gray)! }
    public static func darkGray() -> UIImage { return UIImage.resizable(color:UIColor.darkGray)! }
    public static func lightGray() -> UIImage { return UIImage.resizable(color:UIColor.lightGray)! }
    public static func white() -> UIImage { return UIImage.resizable(color:UIColor.white)! }
    public static func red() -> UIImage { return UIImage.resizable(color:UIColor.red)! }
    public static func green() -> UIImage { return UIImage.resizable(color:UIColor.green)! }
    public static func blue() -> UIImage { return UIImage.resizable(color:UIColor.blue)! }
    public static func cyan() -> UIImage { return UIImage.resizable(color:UIColor.cyan)! }
    public static func yellow() -> UIImage { return UIImage.resizable(color:UIColor.yellow)! }
    public static func magenta() -> UIImage { return UIImage.resizable(color:UIColor.magenta)! }
    public static func orange() -> UIImage { return UIImage.resizable(color:UIColor.orange)! }
    public static func purple() -> UIImage { return UIImage.resizable(color:UIColor.purple)! }
    public static func brown() -> UIImage { return UIImage.resizable(color:UIColor.brown)! }
    public static func clear() -> UIImage { return UIImage.resizable(color:UIColor.clear)! }
}
