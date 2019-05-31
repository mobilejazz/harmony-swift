//
//  AppDelegate.swift
//  Harmony
//
//  Created by Joan Martin on 11/27/2017.
//  Copyright (c) 2017 Joan Martin. All rights reserved.
//

import UIKit
import MJCocoaCore
import Harmony

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
        
        let dataSource1 = DeviceStorageDataSource<Int>(UserDefaults.standard, storageType: .rootKey("test"))
        dataSource1.get("key1").then { print("value: \($0)") }.fail { print("error: \($0)") }
        dataSource1.getAll("key2").then { print("value: \($0)") }.fail { print("error: \($0)") }
        dataSource1.put(42, forId: "key1")
        dataSource1.putAll([1,2,3], forId: "key2")
        dataSource1.get("key1").then { print("value: \($0)") }.fail { print("error: \($0)") }
        dataSource1.getAll("key2").then { print("value: \($0)") }.fail { print("error: \($0)") }
        
        let dataSource2 = DeviceStorageDataSource<String>(UserDefaults.standard, storageType: .rootKey("test"))
        dataSource2.get("key3").then { print("value: \($0)") }.fail { print("error: \($0)") }
        dataSource2.getAll("key4").then { print("value: \($0)") }.fail { print("error: \($0)") }
        dataSource2.put("Hello World", forId: "key3")
        dataSource2.putAll(["a","b","c"], forId: "key4")
        dataSource2.get("key3").then { print("value: \($0)") }.fail { print("error: \($0)") }
        dataSource2.getAll("key4").then { print("value: \($0)") }.fail { print("error: \($0)") }
        
        print("User Defaults: \(UserDefaults.standard.asJSONString())")
        
        dataSource1.deleteAll(AllObjectsQuery())
        dataSource2.deleteAll(AllObjectsQuery())
        
        print("User Defaults: \(UserDefaults.standard.asJSONString())")
        
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

