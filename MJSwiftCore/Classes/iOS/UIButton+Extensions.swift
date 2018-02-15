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
    public func setBackgroundColor(_ color: UIColor, radius: CGFloat = 0.0, for state: UIControlState) {
        let image = UIImage.resizableImage(color: color, radius: radius)
        setBackgroundImage(image, for: state)
    }
    
    public func setBackgroundColor(_ color: UIColor, cornerInset: CornerInset, for state: UIControlState) {
        let image = UIImage.resizableImage(color: color, cornerInset: cornerInset)
        setBackgroundImage(image, for: state)
    }
}
