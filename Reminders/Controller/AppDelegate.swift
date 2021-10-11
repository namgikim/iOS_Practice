//
//  AppDelegate.swift
//  Reminders
//
//  Created by namgi on 2021/09/19.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted: Bool, error: Error?) in
            print("허용여부 \(granted), 오류: \(error?.localizedDescription ?? "nil")")
        }
        
        if let navigationController: UINavigationController = self.window?.rootViewController as? UINavigationController,
           let listInTableViewController: ListInTableViewController = navigationController.viewControllers.first as? ListInTableViewController {
            
            UNUserNotificationCenter.current().delegate = listInTableViewController
        }
        
        return true
    }
    
}

