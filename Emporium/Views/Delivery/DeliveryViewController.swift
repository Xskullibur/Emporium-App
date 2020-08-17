//
//  DeliveryViewController.swift
//  Emporium
//
//  Created by Xskullibur on 16/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie
import CoreLocation
import MapKit
import Contacts
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class DeliveryViewController: UIViewController {

    @IBOutlet weak var directionBtn: MDCButton!
    @IBOutlet weak var completeBtn: MDCButton!
    @IBOutlet weak var animationView: AnimationView!
    
    var order: Order!
    var store: GroceryStore!
    var queueId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Button
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        directionBtn.minimumSize = CGSize(width: 64, height: 48)
        directionBtn.applyOutlinedTheme(withScheme: containerScheme)
        
        completeBtn.minimumSize = CGSize(width: 64, height: 48)
        completeBtn.applyContainedTheme(withScheme: containerScheme)
        
        // Animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
    }
    
    @IBAction func completeDeliveryPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "confirmVC", sender: self)
    }
    
    @IBAction func directionBtnPressed(_ sender: Any) {
        let annotation = DeliveryAnnotation(address: order.deliveryAddress)
        annotation.title = "Destination"
        
        // Show Directions
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
        ]
        
        annotation.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "confirmVC" {
            let vc = segue.destination as! ConfirmationViewController
            vc.store = store
            vc.queueId = queueId
        }
        
    }

}
