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

import UIKit

public extension UIView {
    
    /// Returns a view instance created from a XIB
    ///
    /// - Parameter nibName: The nib name or nothing to use a nib name with the same name as the view class
    /// - Returns: The view
    public static func fromNib<T>(nibName: String = String(describing: T.self)) -> T where T:UIView {
        let nib = UINib(nibName: nibName, bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first! as! T
        return view
    }
    
    public func subviews(passingTest test: (UIView) -> Bool, views: (UIView) -> Void) {
        var subviews : [UIView] = []
        subviews.append(self)
        while subviews.count > 0 {
            let view = subviews.first!
            subviews.remove(at: 0)
            if view != self && test(view) {
                views(view)
            }
            subviews.append(contentsOf:view.subviews)
        }
    }
    
    public func subviews(passingTest test: (UIView) -> Bool) -> [UIView] {
        var array : [UIView] = []
        subviews(passingTest: test) { view in
            array.append(view)
        }
        return array
    }
    
    public func subviews<T>(ofType type: T.Type) -> [UIView] where T : UIView {
        return subviews { view -> Bool in
            return view.self === type
        }
    }
    
    public func subviews<T>(ofType type: T.Type, views: (UIView) -> Void) where T : UIView {
        return subviews(passingTest: { view -> Bool in
            return view.self === type
        }, views: views)
    }
    
    public func subviews(withTag tag: Int) -> [UIView] {
        return subviews { view -> Bool in
            return view.tag == tag
        }
    }
    
    public func subviews(withTag tag: Int, views: (UIView) -> Void) {
        return subviews(passingTest: { view -> Bool in
            return view.tag == tag
        }, views: views)
    }
    
    public func subviews(withAccessibilityIdentifier id: String) -> [UIView] {
        return subviews { view -> Bool in
            return view.accessibilityIdentifier == id
        }
    }
    
    public func subviews(withAccessibilityIdentifier id: String, views: (UIView) -> Void) {
        return subviews(passingTest: { view -> Bool in
            return view.accessibilityIdentifier == id
        }, views: views)
    }
    
    public func allSubviews() -> [UIView] {
        return subviews { view -> Bool in
            return true
        }
    }
    
    public func toImage() -> UIImage {
        if bounds.size.equalTo(CGSize.zero) {
           return UIImage()
        }
        let alpha = self.alpha
        self.alpha = 1
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        UIGraphicsEndImageContext()
        self.alpha = alpha
        return image
    }
}
