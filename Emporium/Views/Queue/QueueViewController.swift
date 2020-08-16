//
//  QueueViewController.swift
//  Emporium
//
//  Created by Xskullibur on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MapKit

import FirebaseFunctions
import FirebaseFirestore
import FirebaseAuth

import MaterialComponents.MaterialCards
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class QueueViewController: UIViewController {

    // MARK: - Variable
    var queueDataManager = QueueDataManager()
    var storeDataManager = StoreDataManager()
    
    var justJoinedQueue = false
    var store: GroceryStore?
    var queueId: String?
    var queueLength: String?
    var currentlyServing: String?
    var _order: Order?
    var listenerManager: ListenerManager = ListenerManager()
    
    var functions = Functions.functions()

    // MARK: - Outlets
    @IBOutlet weak var leaveQueueBtn: MDCButton!
    @IBOutlet weak var requestItemBtn: MDCButton!
    @IBOutlet weak var cardView: MDCCard!
    @IBOutlet weak var currentlyServingLbl: UILabel!
    @IBOutlet weak var queueLengthLbl: UILabel!
    @IBOutlet weak var queueNumberLbl: UILabel!
    
    // MARK: - IBAction
    @IBAction func requestItemBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showRequestorItem", sender: self)
    }
    
    @IBAction func leaveBtnPressed(_ sender: Any) {
        
        // Confirm Alert
        let alert = UIAlertController(
            title: "Are you sure",
            message: "Are you sure you would like to leave the queue?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // MARK: [Leave Queue]
            let userId = Auth.auth().currentUser!.uid
            self.showSpinner(onView: self.view)
            self.queueDataManager.leaveQueue(storeId: self.store!.id, queueId: self.queueId!, userId: userId) { (success) in
                
                self.removeSpinner()
                if success {

                    // Show Success Alert and Navigate
                    self.showAlert(title: "Success", message: "Successfully Left Queue") {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                }
                else {
                    
                    // Error Alert
                    let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
                    let data = Plist.readPlist(url!)!
                    let infoDescription = data["Error Alert"] as! String
                    self.showAlert(title: "Oops", message: infoDescription)
                    
                }
                
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        functions.useFunctionsEmulator(origin: Global.FIREBASE_HOST)
        
        // User Interface
        /// Title
        navigationItem.title = "\(store!.name) (\(store!.address))"
        
        /// Buttons
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        leaveQueueBtn.minimumSize = CGSize(width: 64, height: 48)
        leaveQueueBtn.applyContainedTheme(withScheme: containerScheme)
        
        requestItemBtn.minimumSize = CGSize(width: 64, height: 48)
        requestItemBtn.applyOutlinedTheme(withScheme: containerScheme)
        
        if let _ = _order {
            requestItemBtn.isHidden = false
        }
        
        /// CardView
        cardView.cornerRadius = 13
        cardView.clipsToBounds = true
        cardView.setBorderWidth(1, for: .normal)
        cardView.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cardView.layer.masksToBounds = false
        cardView.setShadowElevation(ShadowElevation(6), for: .normal)
        
        // Values
        queueNumberLbl.text = QueueItem.hash_id(str: queueId!)
        
        if currentlyServing != nil && queueLength != nil {
            currentlyServingLbl.text = String(currentlyServing!)
            queueLengthLbl.text = String(queueLength!)
        }
        
        // Setup
        if justJoinedQueue {
            showVolunteerAlert()
        }
        
        // Visitor Count Listener
        let listener = createListener()
        listenerManager.add(listener)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listenerManager.clear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let listener = createListener()
        listenerManager.add(listener)
    }
    
    // MARK: - Custom Functions
    func createListener() -> ListenerRegistration {
        // Error Alert
        let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
        let data = Plist.readPlist(url!)!
        let infoDescription = data["Error Alert"] as! String
        
        // MARK: [Store Listener]
        return storeDataManager.storeListener(store!) { (data) in
            
            // Guard Data
            guard let current_visitor_count = data["current_visitor_count"] as? Int,
                let max_capacity_count = data["max_visitor_capacity"] as? Int else {
                    print("Field data was empty. (VisitorCount.Listener)")
                    self.showAlert(title: "Oops!", message: infoDescription)
                    return
            }
            
            // Check for visitor count change
            if current_visitor_count < max_capacity_count{
                // Get next person in Queue
                self.queueDataManager.popQueue(storeId: self.store!.id, onComplete: { (data) in
                        
                    // Guard Data for nulls
                    guard let currentQueueId = data["currentQueueId"] as? String, let queueLength = data["queueLength"] as? String else {
                        print("Field data was empty. (popQueue.Functions)")
                        self.showAlert(title: "Oops!", message: infoDescription)
                        return
                    }
                    
                    // Navigate if currently serving user
                    if currentQueueId == self.queueId {
                        
                        // Clear Listeners
                        self.listenerManager.clear()
                        
                        // Navigate to Entry
                        let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                        
                        let entryVC = queueStoryboard.instantiateViewController(identifier: "entryVC") as EntryViewController
                        entryVC.store = self.store
                        entryVC.queueId = self.queueId!
                        entryVC.order = self._order
                        
                        let rootVC = self.navigationController?.viewControllers.first
                        self.navigationController?.setViewControllers([rootVC!, entryVC], animated: true)
                        
                    }
                    else {
                        // Update cards
                        self.queueLengthLbl.text = queueLength
                        self.currentlyServingLbl.text = QueueItem.hash_id(str: currentQueueId)
                    }
                    
                }) { (error) in
                    // Error
                    self.showAlert(title: "Oops!", message: infoDescription)
                }

            }
            else {
                
                // Get Queue Number and Queue Length
                self.queueDataManager.getQueueInfo(storeId: self.store!.id) { (currentlyServing, queueLength) in
                    self.currentlyServingLbl.text = QueueItem.hash_id(str: currentlyServing)
                    self.queueLengthLbl.text = queueLength
                }

            }
        }
    }
    
    func showVolunteerAlert() {
        let alert = UIAlertController(
            title: "Would you like to volunteer?",
            message: "Volunteer to help your fellow neighbours get groceries",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            //Send delivery request to server
            DeliveryDataManager.checkVolunteerRequest(storeId: self.store!.id, receiveOrder: {
                order in
                if let order = order {
                    let content = LocalNotificationHelper.createNotificationContent(title: "Volunteer Alert", body: "Someone has requested you to help get groceries!", subtitle: "", others: nil)
                    LocalNotificationHelper.addNotification(identifier: "Order.notification", content: content)
                    self._order = order
                    DispatchQueue.main.async {
                        self.requestItemBtn.isHidden = false
                    }
                    
                    //TEST
                    DeliveryDataManager.shared.getDeliveryOrder(onComplete: {
                        order1 in
                        print("Recieved delivery order: \(order1!.orderID)")
                        
                        DeliveryDataManager.shared.updateDeliveryStatus(status: .completed)
                        
                    })
                    //TEST
                    
                    print("Recieved order: \(order.orderID)")
                }
            })
            //Start Background fetch
//            UserDefaults.standard.set(self.store!.id, forKey: "com.emporium.requestOrder:storeId")
//            (UIApplication.shared.delegate as! AppDelegate).scheduleFetchOrder()
            
            let thanksAlert = UIAlertController(
                title: "Thank you!",
                message: "We will notify you when there is a request.",
                preferredStyle: .alert
            )
            thanksAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(thanksAlert, animated: true)
            
        }))
        
        self.present(alert, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showRequestorItem" {
            let requestorListVC = segue.destination as! RequestorsListViewController
            requestorListVC.store = store!
            requestorListVC.queueId = queueId!
            requestorListVC.order = _order!
        }
        
    }

}
