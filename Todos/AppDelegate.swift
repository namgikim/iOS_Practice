//
//  AppDelegate.swift
//  Todos
//
//  Created by namgi on 2021/07/01.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // User Notification Center를 통해서 노티피케이션 권한 획득
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [UNAuthorizationOptions.alert, UNAuthorizationOptions.sound, UNAuthorizationOptions.badge]) { (granted, error) in
            print("허용여부 \(granted), 오류 : \(error?.localizedDescription ?? "없음")")
        }
        
        // 맨 처음 화면의 뷰 컨트롤러(TodosTableViewController)를 UserNotificationCenter의 delegate로 설정
        if let navigationController: UINavigationController = self.window?.rootViewController as? UINavigationController, let todosTableViewController: TodosTableViewController = navigationController.viewControllers.first as? TodosTableViewController {
            
            UNUserNotificationCenter.current().delegate = todosTableViewController
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

