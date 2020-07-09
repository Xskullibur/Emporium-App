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
    var functions = Functions.functions()

    // MARK: - Outlets
    @IBOutlet weak var leaveQueueBtn: MDCButton!
    @IBOutlet weak var cardView: MDCCard!
    @IBOutlet weak var currentlyServingLbl: UILabel!
    @IBOutlet weak var queueLengthLbl: UILabel!
    @IBOutlet weak var queueNumberLbl: UILabel!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG
        let functionsHost = ProcessInfo.processInfo.environment["functions_host"]
        if let functionsHost = functionsHost {
            functions.useFunctionsEmulator(origin: functionsHost)
        }
        #endif
        
        // User Interface
        /// Title
        navigationItem.title = "\(store!.name) (\(store!.address))"
        
        /// Buttons
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        leaveQueueBtn.minimumSize = CGSize(width: 64, height: 48)
        leaveQueueBtn.applyContainedTheme(withScheme: containerScheme)
        
        /// CardView
        cardView.cornerRadius = 13
        cardView.clipsToBounds = true
        cardView.setBorderWidth(1, for: .normal)
        cardView.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cardView.layer.masksToBounds = false
        cardView.setShadowElevation(ShadowElevation(6), for: .normal)
        
        // Values
        queueNumberLbl.text = queueId!
        queueLengthLbl.text = queueLength!
        currentlyServingLbl.text = currentlyServing!
        
        // Setup
        if justJoinedQueue {
            
            // Show Volunteer Alert
            showVolunteerAlert()
            
            // Visitor Count Listener
            storeDataManager.visitorCountListenerForStore(store!) { (current_visitor_count, max_capacity_count) in
                
                if current_visitor_count < max_capacity_count{
                    // Get next person in Queue
                    self.functions.httpsCallable("popQueue").call(["queueId": self.queueId, "storeId": self.store!.id]) { (result, error) in
                        
                        // Error
                        if let error = error as NSError? {
                            if error.domain == FunctionsErrorDomain{
                                let code = FunctionsErrorCode(rawValue: error.code)?.rawValue
                                let message = error.localizedDescription
                                let details = error.userInfo[FunctionsErrorDetailsKey].debugDescription
                                
                                print("Error joining queue: Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                            }
                        }
                        
                        // Data found
                        if let data = (result?.data as? [String: Any]) {
                            
                            let currentQueueId: String = data["currentQueueId"] as! String
                            let queueLength: String = data["queueLength"] as! String
                            
                            // Navigate if currently serving user
                            if currentQueueId == self.queueId {
                                let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                                let entryVC = queueStoryboard.instantiateViewController(identifier: "entryVC") as EntryViewController
                                entryVC.store = self.store
                                
                                self.present(entryVC, animated: true, completion: nil)
                            }
                            else {
                                // Update cards
                                self.queueLengthLbl.text = queueLength
                                self.currentlyServingLbl.text = currentQueueId
                            }
                            
                        }
                        
                    }
                }
                else {
                    
                    // Get Queue Number and Queue Length
                    self.queueDataManager.getQueueInfo(storeId: self.store!.id) { (currentlyServing, queueLength) in

                        self.currentlyServingLbl.text = currentlyServing
                        self.queueLengthLbl.text = queueLength
                        
                    }

                }
            }
            
        }
        
    }
    
    // MARK: - Custom Functions
    func showVolunteerAlert() {
        let alert = UIAlertController(
            title: "Would you like to volunteer?",
            message: "Volunteer to help your fellow neighbours get groceries",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            let thanksAlert = UIAlertController(
                title: "Thank you!",
                message: "You will be notified when there is a request.",
                preferredStyle: .alert
            )
            thanksAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(thanksAlert, animated: true)
            
        }))
        
        self.present(alert, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "debug.entryVC" {
            let entryVC = segue.destination as! EntryViewController
            entryVC.store = store
        }
        
    }

}
