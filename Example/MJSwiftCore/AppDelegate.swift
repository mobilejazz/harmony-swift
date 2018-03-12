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
import Promises

class Dog : DataConvertible, CustomStringConvertible {
    var description: String {
        return "Dog named \(name) of \(age) years old"
    }
    
    let name : String
    let age : Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    public required init?(data: Data) {
        let archiver = NSKeyedUnarchiver(forReadingWith: data)
        self.name = archiver.decodeObject(forKey: "name") as! String
        self.age = archiver.decodeInteger(forKey: "age")
    }
    
    public var data: Data {
        let archiver = NSKeyedArchiver()
        archiver.encode(name, forKey: "name")
        archiver.encode(age, forKey: "age")
        return archiver.encodedData
    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

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
                
        //let repository = KeychainRepository<Data>(Keychain())
        let repository = UserDefaultsRepository<Data>(UserDefaults.standard)
        
        let mappedRepository = MappedRepository<Dog,Data>(repository: repository,
                                                          toToMapper: toDataMapper<Dog>(),
                                                          toFromMapper: toDataConvertibleMapper<Dog>())
        
        let dataProvider = RepositoryDataProvider<Dog>(repository: mappedRepository)
        
        let dog = Dog(name:"Lassie", age: 6)
        
        dataProvider.get(KeyQuery("test.key")).unwrap().then { value in
            print("Value: \(value)")
            }.fail { error in
                print("Error: \(error)")
        }
        
        dataProvider.put(KeyValueQuery<Dog>("test.key", dog)).then { result in
            print("Result: \(result)")
            }.fail { error in
                print("Error: \(error)")
        }
        
        dataProvider.get(KeyQuery("test.key")).unwrap().then { value in
            print("Value: \(value)")
            }.fail { error in
                print("Error: \(error)")
        }
        
        dataProvider.delete(KeyQuery("test.key")).then { result in
            print("Result: \(result)")
            }.fail { error in
                print("Error: \(error)")
        }
        
        dataProvider.get(KeyQuery("test.key")).unwrap().then { value in
            print("Value: \(value)")
            }.fail { error in
                print("Error: \(error)")
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

