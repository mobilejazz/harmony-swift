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

public enum ContainerAnimation {
    case none
    case crossDisolve
    case newModalBottom
    case oldModalBottom
}

private let animationDuration : Double = 0.40
private let animationOptions = UIViewAnimationOptions(rawValue:(7<<16))

public class ContainerViewController: UIViewController {
    
    public private(set) var viewController : UIViewController?
    
    public convenience init(_ viewController: UIViewController) {
        self.init(nibName: nil, bundle: nil)
        self.viewController = viewController
    }
    
    public func setViewController(_ viewController: UIViewController, animation: ContainerAnimation = .none) {
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
            
            if let oldVC = oldVC {
                oldVC.willMove(toParentViewController: nil)
                self.addChildViewController(newVC)
                
                switch (animation) {
                case .none:
                    oldVC.view.removeFromSuperview()
                    self.view.insertSubview(newVC.view, at: 0)
                    oldVC.removeFromParentViewController()
                    newVC.didMove(toParentViewController: self)
                case .crossDisolve:
                    self.view.insertSubview(newVC.view, belowSubview: oldVC.view)
                    UIView.animate(withDuration: animationDuration,
                                   delay: 0,
                                   options: animationOptions,
                                   animations: {
                                    oldVC.view.alpha = 0.0
                    },
                                   completion: { (success) in
                                    oldVC.view.removeFromSuperview()
                                    oldVC.removeFromParentViewController()
                                    newVC.didMove(toParentViewController: self)
                    })
                case .newModalBottom:
                    newVC.view.alpha = 0.0
                    newVC.view.frame = self.view.bounds.offsetBy(dx: 0, dy: UIScreen.main.bounds.size.height)
                    self.view.insertSubview(newVC.view, aboveSubview: oldVC.view)
                    UIView.animate(withDuration: animationDuration,
                                   delay: 0,
                                   options: animationOptions,
                                   animations: {
                                    newVC.view.alpha = 1.0
                                    newVC.view.frame = self.view.bounds
                    },
                                   completion: { (success) in
                                    oldVC.view.removeFromSuperview()
                                    oldVC.removeFromParentViewController()
                                    newVC.didMove(toParentViewController: self)
                    })
                case .oldModalBottom:
                    let frame = self.view.bounds.offsetBy(dx: 0, dy: UIScreen.main.bounds.size.height)
                    self.view.insertSubview(newVC.view, belowSubview: oldVC.view)
                    UIView.animate(withDuration: animationDuration,
                                   delay: 0,
                                   options: animationOptions,
                                   animations: {
                                    oldVC.view.alpha = 0.0
                                    oldVC.view.frame = frame
                    },
                                   completion: { (success) in
                                    oldVC.view.removeFromSuperview()
                                    oldVC.removeFromParentViewController()
                                    newVC.didMove(toParentViewController: self)
                    })
                }
            } else {
                let subview = viewController.view!
                subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                subview.frame = self.view.bounds
                addChildViewController(viewController)
                self.view.addSubview(subview)
                viewController.didMove(toParentViewController: self)
            }
        } else {
            // View not loaded yet. Just storing the instance for later processing
            self.viewController = viewController
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewController = viewController {
            if !self.childViewControllers.contains(viewController) {
                let subview = viewController.view!
                subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                subview.frame = self.view.bounds
                
                addChildViewController(viewController)
                self.view.addSubview(subview)
                viewController.didMove(toParentViewController: self)
            }
        }
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.subviews.first?.frame = self.view.bounds
    }
    
    override public func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if let viewController = viewController {
            if parent != nil {
                addChildViewController(viewController)
            } else {
                viewController.willMove(toParentViewController: nil)
            }
        }
    }
    
    override public func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if let viewController = viewController {
            if parent != nil {
                viewController.didMove(toParentViewController: self)
            } else {
                viewController.removeFromParentViewController()
            }
        }
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if let vc = viewController {
                return vc.preferredStatusBarStyle
            } else {
                return super.preferredStatusBarStyle
            }
        }
    }
    
    override public var shouldAutorotate: Bool {
        get {
            if let vc = viewController {
                return vc.shouldAutorotate
            } else {
                return super.shouldAutorotate
            }
        }
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            if let vc = viewController {
                return vc.supportedInterfaceOrientations
            } else {
                return super.supportedInterfaceOrientations
            }
        }
    }
}

public extension UIViewController {
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
