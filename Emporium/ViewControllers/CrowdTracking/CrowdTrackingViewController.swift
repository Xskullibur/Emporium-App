//
//  CrowdTrackingViewController.swift
//  Emporium
//
//  Created by Riyfhx on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards

class CrowdTrackingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var cardView: MDCCard!
    
    @IBOutlet weak var noOfShopperLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // User Interface
        /// CardView
        cardView.cornerRadius = 13
        cardView.clipsToBounds = true
        cardView.setBorderWidth(1, for: .normal)
        cardView.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cardView.layer.masksToBounds = false
        cardView.setShadowElevation(ShadowElevation(6), for: .normal)
    }
    
    /**
        IBAction for stepper, use for manually controlling the amount of shopper inside the supermarket.
     */
    @IBAction func changeNoOfShoppersStepper(_ sender: Any) {
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
