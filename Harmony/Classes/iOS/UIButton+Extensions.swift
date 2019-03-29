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

public extension UIButton {
    func setBackgroundColor(_ color: UIColor, radius: CGFloat = 0.0, for state: UIControl.State) {
        let image = UIImage.resizable(color: color, radius: radius)
        setBackgroundImage(image, for: state)
    }
    
    func setBackgroundColor(_ color: UIColor, cornerInset: CornerInset, for state: UIControl.State) {
        let image = UIImage.resizable(color: color, cornerInset: cornerInset)
        setBackgroundImage(image, for: state)
    }
    
    @objc func alignImageAndTitleVertically(padding: CGFloat = 6.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height),
                                            left: 0,
                                            bottom: 0,
                                            right: -titleSize.width)
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0,
                                            left: -imageSize.width,
                                            bottom: -(totalHeight - titleSize.height),
                                            right: 0)
    }
}
