//
//  AppDelegate.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 15.01.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit
import AERecord
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         EPGHelper.getInstance()?.preload()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        //let l = self.window?.rootViewController as? ViewController
        //l?.stop()
        //let l = self.window?.rootViewController as? ViewController
        //l?.stop()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let l = self.window?.rootViewController as? ViewController
        l?.stop()// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let l = self.window?.rootViewController as? ViewController
        l?.perform(#selector(ViewController.start), with: nil, afterDelay: 1.0)
        l?.perform(#selector(ViewController.checkSettings), with: nil, afterDelay: 1.0)
        
        
//        EPGHelper.getInstance()?.preload()
        
        //let l = self.window?.rootViewController as? ViewController
        //l?.start()// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //EPGHelper.preloadingEPG()
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        application.isIdleTimerDisabled = true
        return true
    }

}

