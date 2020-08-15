//
//  AppDelegate.swift
//  Emporium
//
//  Created by Peh Zi Heng on 19/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import CoreData
import Combine
import Firebase
import FirebaseUI
import Stripe
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private var cancellables: Set<AnyCancellable>? = Set<AnyCancellable>()
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        Stripe.setDefaultPublishableKey("pk_test_tFCu0UObLJ3OVCTDNlrnhGSt00vtVeIOvM")
        
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
          return true
        }
        // other URL handling goes here.
        return false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //Set Nav bar color
        let navigationBarAppearace = UINavigationBar.appearance()

        navigationBarAppearace.tintColor = UIColor(named: "Primary")
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(named: "Primary")!]
        navigationBarAppearace.barTintColor = UIColor(named: "Background")
        
        let notificationHandler = NotificationHandler.shared
        notificationHandler.create()
        notificationHandler.start()
        notificationHandler.getNotifications()?.sink(receiveCompletion: { (completion) in
            print(completion)
        }, receiveValue: { (notifications) in
            
            for notification in notifications {
                let content = LocalNotificationHelper.createNotificationContent(
                    title: notification.title,
                    body: notification.message,
                    subtitle: notification.sender,
                    others: nil
                )
                LocalNotificationHelper.addNotification(identifier: notification.date.toBasicDateString() + ".notification", content: content)
            }
            
        })
        
        // Local Notification
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        //Request orders
        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: "com.emporium.requestOrder",
          using: nil) { (task) in
            let bgtask = task as! BGAppRefreshTask
            bgtask.expirationHandler = {
                bgtask.setTaskCompleted(success: false)
                URLSession.shared.invalidateAndCancel()
            }
            
            let storeId = UserDefaults.standard.string(forKey: "com.emporium.requestOrder:storeId")
            
            if let storeId = storeId {
                DeliveryDataManager.checkVolunteerRequest(storeId: storeId, receiveOrder: {
                    order in
                    if let order = order {
                        let content = LocalNotificationHelper.createNotificationContent(title: "New Order", body: "You have a new order", subtitle: "", others: nil)
                        LocalNotificationHelper.addNotification(identifier: "Order.notification", content: content)
                        print("Recieved order: \(order.orderID)")
                    }else{
                        self.scheduleFetchOrder()
                    }
                })
                self.scheduleFetchOrder()
            }
            
        }
        
        //Listen for rewards
        let earnedRewardsDataManager = EarnedRewardsDataManager.shared
        earnedRewardsDataManager.getEarnedRewards()
            .sink(receiveCompletion: {
                completion in
            }, receiveValue: {
                earnedRewards in
                for earnedReward in earnedRewards {
                    //Display Gift View Controller if the earned rewards is not shown to the user before
                    if !earnedReward.displayed{
                        let storyboard = UIStoryboard.init(name: "Rewards", bundle: nil)
                        let viewController = storyboard.instantiateViewController(identifier: "GiftPointsViewController") as GiftPointsViewController
                        
                        viewController.setEarnedReward(earnedReward: earnedReward)
                        viewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                        viewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        
                        let rootViewController = UIApplication.shared.windows.first!.rootViewController
                        rootViewController?.present(viewController, animated: true, completion: nil)
                    }
                }
            }).store(in: &cancellables!)
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.cancellables = nil
    }

    //MARK: Background Scheduler
    func scheduleFetchOrder(){
        let requestOrderTask = BGAppRefreshTaskRequest(identifier: "com.emporium.requestOrder")
        requestOrderTask.earliestBeginDate = Date(timeIntervalSinceNow: 30)
        do {
            try BGTaskScheduler.shared.submit(requestOrderTask)
        }catch {
            print("Unable to submit task: \(error.localizedDescription)")
        }
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Emporium")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Local Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\n\nRECEIVED!\n\n")
        completionHandler()
    }
    
}

