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

    // MARK: - Outlets
    @IBOutlet weak var directionBtn: MDCButton!
    @IBOutlet weak var leaveQueueBtn: MDCButton!
    @IBOutlet weak var cardView: MDCCard!
    
    // MARK: - IBActions
    @IBAction func directionBtnPressed(_ sender: Any) {
        // Add Store Annotation
        let annotation = StoreAnnotation(
            coords: CLLocationCoordinate2D(
                latitude: store!.latitude,
                longitude: store!.longitude
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
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // User Interface
        /// Title
        navigationItem.title = "\(store!.name) (\(store!.address))"
        
        /// Buttons
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        directionBtn.minimumSize = CGSize(width: 64, height: 48)
        directionBtn.applyContainedTheme(withScheme: containerScheme)
        
        leaveQueueBtn.minimumSize = CGSize(width: 64, height: 48)
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
    

//    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }

}
