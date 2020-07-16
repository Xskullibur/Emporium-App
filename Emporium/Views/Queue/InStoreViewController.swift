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

class InStoreViewController: UIViewController {

    // MARK: - Variables
    var queueId: String?
    var storeId: String?
    
    // MARK: - Outlets
    @IBOutlet weak var exitStoreBtn: MDCButton!
    @IBOutlet weak var requestorListBtn: MDCButton!
    @IBOutlet weak var animationView: AnimationView!
    
    // MARK: - IBActions
    @IBAction func exitBtnPressed(_ sender: Any) {
    }
    @IBAction func requestorListBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowRequestorList", sender: self)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animation
        animationView.animation = Animation.named("shopping-bag")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        // Button
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        exitStoreBtn.minimumSize = CGSize(width: 64, height: 48)
        exitStoreBtn.applyContainedTheme(withScheme: containerScheme)
        
        requestorListBtn.minimumSize = CGSize(width: 64, height: 48)
        requestorListBtn.applyOutlinedTheme(withScheme: containerScheme)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowRequestorList" {
            let requestorListVC = segue.destination as! RequestorsListViewController
            requestorListVC.storeId = storeId!
            requestorListVC.queueId = queueId!
        }
        
    }

}
