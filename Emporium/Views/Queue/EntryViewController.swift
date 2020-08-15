//
//  EntryViewController.swift
//  Emporium
//
//  Created by Xskullibur on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Lottie
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import CoreBluetooth

class EntryViewController: UIViewController {

    // MARK: - Variable
    var store: GroceryStore?
    var queueId: String?
    var order: Order?
    
    // MARK: - Outlet
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var directionBtn: MDCButton!
    @IBOutlet weak var enterStoreBtn: MDCButton!
    
    // MARK: - IBActions
    @IBAction func directionBtnPressed(_ sender: Any) {
        let annotation = StoreAnnotation(
            coords: CLLocationCoordinate2D(
                latitude: store!.location.latitude,
                longitude: store!.location.longitude
            ),
            store: store!
        )
        annotation.title = store!.name
        annotation.subtitle = store!.address
        
        // Show Directions
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
        ]
        
        annotation.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    @IBAction func enterStoreButtonPressed(_ sender: Any) {
        
        self.showSpinner(onView: self.view)
        
        let queueDataManager = QueueDataManager()
        queueDataManager.updateQueue(queueId!, withStatus: QueueStatus.InStore, forStoreId: store!.id) { (success) in
            
            self.removeSpinner()
            
            if success {
                // Navigate to InStore
                let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                
                let inStoreVC = queueStoryboard.instantiateViewController(identifier: "inStoreVC") as InStoreViewController
                inStoreVC.queueId = self.queueId
                inStoreVC.store = self.store
                inStoreVC.order = self.order
                
                let rootVC = self.navigationController?.viewControllers.first
                self.navigationController?.setViewControllers([rootVC!, inStoreVC], animated: true)
                
                // Add Local Notification
                let notificationContent = LocalNotificationHelper.createNotificationContent(
                    title: "Welcome to \(self.store!.name)!",
                    body: "Wish you have a nice day.",
                    subtitle: nil,
                    others: nil
                )
                LocalNotificationHelper.addNotification(identifier: "InStore.Notification", content: notificationContent)
            }
            
        }
        
    }
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reminder
        if Bool.random() {
            animationView.animation = Animation.named("wear-mask")
            reminderLabel.text = "Remember to wear a mask."
        }
        else {
            animationView.animation = Animation.named("social-distancing")
            reminderLabel.text = "Remember to practice safe distancing."
        }
        
        // Animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        // Button
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        directionBtn.minimumSize = CGSize(width: 64, height: 48)
        directionBtn.applyOutlinedTheme(withScheme: containerScheme)
        
        enterStoreBtn.minimumSize = CGSize(width: 64, height: 48)
        enterStoreBtn.applyContainedTheme(withScheme: containerScheme)
        
        // onResume
        NotificationCenter.default.addObserver(self,
            selector: #selector(playAnimation),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }
    
    @objc func playAnimation() {
        animationView.play()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NotificationCenter.default.removeObserver(self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

}
