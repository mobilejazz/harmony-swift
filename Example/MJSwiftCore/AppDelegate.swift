//
//  AppDelegate.swift
//  MJSwiftCore
//
//  Created by Joan Martin on 11/27/2017.
//  Copyright (c) 2017 Joan Martin. All rights reserved.
//

import UIKit

import MJSwiftCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let splash = SplashViewController()
        let container = ContainerViewController(splash)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = container
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateInitialViewController()!
            container.setViewController(mainVC, animation: .crossDisolve)
        }
        
        
//        let linkRecognizer = LinkRecognizer(scheme: "mjz", options: [.CaseInsensitive, .AnchoredStart, .AnchoredEnd])
//        
//        linkRecognizer.registerPattern("//screen/tomorrow", forKey: "tomorrow")
//        linkRecognizer.registerPattern("//screen/today/\(LinkRecognizer.Pattern.numeric)", forKey: "today")
//        linkRecognizer.registerPattern("//screen/yesterday/\(LinkRecognizer.Pattern.alphanumeric)/index", forKey: "yesterday")
//        
//        let result1 = linkRecognizer.recognize(URL(string:"mjz://screen/today/1234")!)
//        let result2 = linkRecognizer.recognize(URL(string:"mjz://screen/tomorrow")!)
//        let result3 = linkRecognizer.recognize(URL(string:"mjz://screen/yesterday/o239hf2oisdh9/index")!)
//        
//        NSLog("Result 1: \(result1)")
//        NSLog("Result 2: \(result2)")
//        NSLog("Result 3: \(result3)")
        
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

