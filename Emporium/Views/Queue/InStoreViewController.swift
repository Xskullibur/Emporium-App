//
//  InStoreViewController.swift
//  Emporium
//
//  Created by Xskullibur on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import Lottie
import CoreBluetooth

class InStoreViewController: UIViewController {

    // MARK: - Variables
    var queueId: String?
    var store: GroceryStore?
    var order: Order?
    
    // MARK: - Outlets
    @IBOutlet weak var exitStoreBtn: MDCButton!
    @IBOutlet weak var requestorListBtn: MDCButton!
    @IBOutlet weak var animationView: AnimationView!
    
    // MARK: - IBActions
    @IBAction func exitBtnPressed(_ sender: Any) {
        
        showSpinner(onView: self.view)
        
        let queueDataManager = QueueDataManager()
        queueDataManager.updateQueue(queueId!, withStatus: .Completed, forStoreId: store!.id) { (success) in
            
            self.removeSpinner()
            
            if success {
                // Add Local Notification
                let notificationContent = LocalNotificationHelper.createNotificationContent(
                    title: "Thank you for shopping at \(self.store!.name)!",
                    body: "Have a nice day.",
                    subtitle: nil,
                    others: nil
                )
                LocalNotificationHelper.addNotification(identifier: "InStore.Notification", content: notificationContent)
                self.navigationController?.popToRootViewController(animated: true)
            }
            else {
                // Alert
                let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
                let data = Plist.readPlist(url!)!
                let infoDescription = data["Error Alert"] as! String
                self.showAlert(title: "Oops!", message: infoDescription)
            }
            
        }
    }
    
    @IBAction func requestorListBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowRequestorList", sender: self)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Local Notification
        let notificationContent = LocalNotificationHelper.createNotificationContent(
            title: "Welcome to \(self.store!.name)!",
            body: "Have a nice shopping experience.",
            subtitle: nil,
            others: nil
        )
        LocalNotificationHelper.addNotification(identifier: "InStore.Notification", content: notificationContent)
        
        // Animation
        animationView.animation = Animation.named("shopping-bag")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        // Button
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        exitStoreBtn.minimumSize = CGSize(width: 64, height: 48)
        exitStoreBtn.applyContainedTheme(withScheme: containerScheme)
        
        if let _ = order {
            requestorListBtn.minimumSize = CGSize(width: 64, height: 48)
            requestorListBtn.applyOutlinedTheme(withScheme: containerScheme)
        }
        else {
            requestorListBtn.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowRequestorList" {
            let requestorListVC = segue.destination as! RequestorsListViewController
            requestorListVC.store = store!
            requestorListVC.queueId = queueId!
            requestorListVC.order = order!
        }
        
    }

}
