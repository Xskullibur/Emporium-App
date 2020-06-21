//
//  QueueViewController.swift
//  Emporium
//
//  Created by Xskullibur on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class QueueViewController: UIViewController {

    // MARK: - Variable
    var justJoinedQueue = false
    var store: GroceryStore?

    // MARK: - Outlets
    @IBOutlet weak var directionBtn: MDCButton!
    @IBOutlet weak var leaveQueueBtn: MDCButton!
    @IBOutlet weak var cardView: MDCCard!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // User Interface
        /// Title
        if let store = store {
            navigationItem.title = "\(store.name) (\(store.address))"
        }
        
        /// Buttons
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = .systemOrange
        directionBtn.setBorderColor(.systemOrange, for: .normal)
        directionBtn.setBorderWidth(1, for: .normal)
        directionBtn.applyOutlinedTheme(withScheme: containerScheme)
        leaveQueueBtn.applyOutlinedTheme(withScheme: containerScheme)
        
        /// CardView
        cardView.cornerRadius = 13
        cardView.clipsToBounds = true
        cardView.setBorderWidth(1, for: .normal)
        cardView.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cardView.layer.masksToBounds = false
        cardView.setShadowElevation(ShadowElevation(6), for: .normal)
        
        // Volunteer Prompt
        if justJoinedQueue {
            
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
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
