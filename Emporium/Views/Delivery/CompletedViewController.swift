//
//  CompletedViewController.swift
//  Emporium
//
//  Created by ITP312Grp1 on 7/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class CompletedViewController: UIViewController {

    @IBOutlet weak var backToMainBtn: MDCButton!
    @IBOutlet weak var animationView: AnimationView!
    
    var queueId: String!
    var storeId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update Delivery to Completed
        DeliveryDataManager.shared.updateDeliveryStatus(status: .completed)
        let queueDataManager = QueueDataManager()
        queueDataManager.updateQueue(queueId!, withStatus: .Completed, forStoreId: storeId!) { (success) in
            
            AccountDataManager.removeExistingQueue()
            
        }
        
        // AnimationView
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        // Button
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        backToMainBtn.minimumSize = CGSize(width: 64, height: 48)
        backToMainBtn.applyOutlinedTheme(withScheme: containerScheme)
    }
    
    @IBAction func bckToMainPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
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
