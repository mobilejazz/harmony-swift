//
//  AppDelegate.swift
//  Harmony
//
//  Created by Joan Martin on 11/27/2017.
//  Copyright (c) 2017 Joan Martin. All rights reserved.
//

import UIKit
import Harmony

let applicationComponent: ApplicationComponent = ApplicationDefaultModule()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var observable : Observable<Int>!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let splash = SplashViewController()
        let container = ContainerViewController(splash)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = container
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateInitialViewController()!
            container.set(mainVC, animation: .crossDisolve)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

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
    func containerViewController() -> ContainerViewController? {
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
