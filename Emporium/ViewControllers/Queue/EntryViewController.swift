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

class EntryViewController: UIViewController {

    // MARK: - Variable
    var store: GroceryStore?
    
    // MARK: - Outlet
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var directionBtn: MDCButton!
    @IBOutlet weak var enterStoreBtn: MDCButton!
    
    // MARK: - IBActions
    @IBAction func directionBtnPressed(_ sender: Any) {
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
    
    @IBAction func enteryStoreBtnPressed(_ sender: Any) {
    }
    
    
    // MARK: - Lifecycle
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
        animationView.play()
        
        // Button
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        directionBtn.minimumSize = CGSize(width: 64, height: 48)
        directionBtn.applyContainedTheme(withScheme: containerScheme)
        
        enterStoreBtn.minimumSize = CGSize(width: 64, height: 48)
        enterStoreBtn.applyContainedTheme(withScheme: containerScheme)
        
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
