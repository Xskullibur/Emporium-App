//
//  QueueViewController.swift
//  Emporium
//
//  Created by Xskullibur on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MapKit
import MaterialComponents.MaterialCards
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class QueueViewController: UIViewController {

    // MARK: - Variable
    var justJoinedQueue = false
    var store: GroceryStore?
    var queueId: String?

    // MARK: - Outlets
    @IBOutlet weak var leaveQueueBtn: MDCButton!
    @IBOutlet weak var cardView: MDCCard!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        // Volunteer Prompt
        if justJoinedQueue {
            
            // Show Volunteer Alert
            showVolunteerAlert()
            // Create and join queue
            joinQueue()
            
        }
        
    }
    
    // MARK: - Custom Functions
    func joinQueue() {
        
        queueId = QueueDataManager.joinQueue(store: store!)
        
    }
    
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
