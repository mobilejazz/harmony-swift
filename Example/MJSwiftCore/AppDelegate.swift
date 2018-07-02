//
//  AppDelegate.swift
//  MJSwiftCore
//
//  Created by Joan Martin on 11/27/2017.
//  Copyright (c) 2017 Joan Martin. All rights reserved.
//

import UIKit
import MJSwiftCore
import MJCocoaCore

/// Creates and returns a new future, which is resolved 2 seconds after
func future() -> Future<Int> {
    return Future() { resolver in
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2), execute: {
            resolver.set(2)
        })
        }.map { $0*2 }
}

/// Creates and returns a new observable, which is triggered 2 seconds after
func observable() -> Observable<Int> {
    return Observable<Int>() { resolver in
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2), execute: {
            resolver.set(1)
        })
        }.map { $0*2 }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var observable : Observable<Int>!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
                
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
    
        // Observables requires to retain the last item from the chain
//        observable = obs().map { $0*2 }.recover { _ in Observable(0) }.map { $0*2 }
//        observable.then { value in
//            print("observable value: \(value)")
//        }
//        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3), execute: {
//            // when the last chain item is deallocated, the whole chain falls
//            self.observable = nil
//        })
        
        // Futures can be chained and finally opened. The chain will be retained until the root future is resolved.
//        fut().map { $0*2 }.recover { _ in Future(0) }.map { $0*2 }.then { value in
//            print("future value: \(value)")
//        }
        
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

