//
//  AppDelegate.swift
//  tickets
//
//  Created by Oscar Reynaldo Flores Jimenez on 20/05/16.
//  Copyright © 2016 edcatelecomunicaciones.mx. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let socket = SocketIOClient(socketURL: NSURL(string: "http://10.0.6.13:4000")!, options: [.Log(false), .ForcePolling(true)])

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let notifTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let notifSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notifTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notifSettings)
        //background
        application.beginBackgroundTaskWithName("showNotification", expirationHandler: nil)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        socket.reconnect()
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        socket.reconnect()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

