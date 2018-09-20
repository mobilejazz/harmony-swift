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

///
/// Container view controller. A view controller that contains another view controller and
/// can replace it with animations.
///
/// Typically used as the window's rootViewController.
///
public class ContainerViewController: UIViewController {
    
    private static let animationDuration : Double = 0.40
    private static let animationOptions = UIView.AnimationOptions(rawValue:(7<<16))
    
    public enum Animation {
        case none
        case crossDisolve
        case newModalBottom
        case oldModalBottom
    }
    
    /// The contained view controller
    public private(set) var viewController : UIViewController
    
    /// Main initializer
    ///
    /// - Parameter viewController: The view controller to contain
    public required init(_ viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.viewController = UIViewController(nibName: nil, bundle: nil)
        super.init(coder: aDecoder)
    }
    
    /// Sets a new view controller
    ///
    /// - Parameters:
    ///   - viewController: The new view controller
    ///   - animation: The replacement animation
    public func set(_ viewController: UIViewController, animation: Animation = .none) {
        if isViewLoaded {
            // Getting instances on the view controllers
            let oldVC = self.viewController
            let newVC = viewController
            
            // Configuring the new view controller's view
            let subview = viewController.view!
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            subview.frame = self.view.bounds
            
            // Storing the new view controller
            self.viewController = viewController
            
            oldVC.willMove(toParent: nil)
            self.addChild(newVC)
            
            switch (animation) {
            case .none:
                oldVC.view.removeFromSuperview()
                self.view.insertSubview(newVC.view, at: 0)
                oldVC.removeFromParent()
                newVC.didMove(toParent: self)
            case .crossDisolve:
                self.view.insertSubview(newVC.view, belowSubview: oldVC.view)
                UIView.animate(withDuration: ContainerViewController.animationDuration,
                               delay: 0,
                               options: ContainerViewController.animationOptions,
                               animations: {
                                oldVC.view.alpha = 0.0
                },
                               completion: { (success) in
                                oldVC.view.removeFromSuperview()
                                oldVC.removeFromParent()
                                newVC.didMove(toParent: self)
                })
            case .newModalBottom:
                newVC.view.alpha = 0.0
                newVC.view.frame = self.view.bounds.offsetBy(dx: 0, dy: UIScreen.main.bounds.size.height)
                self.view.insertSubview(newVC.view, aboveSubview: oldVC.view)
                UIView.animate(withDuration: ContainerViewController.animationDuration,
                               delay: 0,
                               options: ContainerViewController.animationOptions,
                               animations: {
                                newVC.view.alpha = 1.0
                                newVC.view.frame = self.view.bounds
                },
                               completion: { (success) in
                                oldVC.view.removeFromSuperview()
                                oldVC.removeFromParent()
                                newVC.didMove(toParent: self)
                })
            case .oldModalBottom:
                let frame = self.view.bounds.offsetBy(dx: 0, dy: UIScreen.main.bounds.size.height)
                self.view.insertSubview(newVC.view, belowSubview: oldVC.view)
                UIView.animate(withDuration: ContainerViewController.animationDuration,
                               delay: 0,
                               options: ContainerViewController.animationOptions,
                               animations: {
                                oldVC.view.alpha = 0.0
                                oldVC.view.frame = frame
                },
                               completion: { (success) in
                                oldVC.view.removeFromSuperview()
                                oldVC.removeFromParent()
                                newVC.didMove(toParent: self)
                })
            }
        } else {
            // View not loaded yet. Just storing the instance for later processing
            self.viewController = viewController
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if !self.children.contains(viewController) {
            let subview = viewController.view!
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            subview.frame = self.view.bounds
            
            addChild(viewController)
            self.view.addSubview(subview)
            viewController.didMove(toParent: self)
        }
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.subviews.first?.frame = self.view.bounds
    }
    
    override public func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent != nil {
            addChild(viewController)
        } else {
            viewController.willMove(toParent: nil)
        }
    }
    
    override public func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent != nil {
            viewController.didMove(toParent: self)
        } else {
            viewController.removeFromParent()
        }
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return viewController.preferredStatusBarStyle
        }
    }
    
    override public var shouldAutorotate: Bool {
        get {
            return viewController.shouldAutorotate
        }
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return viewController.supportedInterfaceOrientations
        }
    }
}

public extension UIViewController {
    /// Returns the first ContainerViewController found in the hierarchy.
    ///
    /// - Returns: The first ContainerViewController found in the hierarchy.
    public func containerViewController() -> ContainerViewController? {
        var vc : UIViewController? = self
        while vc != nil {
            if let viewController = vc {
                if viewController.isKind(of: ContainerViewController.self) {
                    return viewController as? ContainerViewController
                }
                vc = viewController.parent
            }
        }
        return nil
    }
}
