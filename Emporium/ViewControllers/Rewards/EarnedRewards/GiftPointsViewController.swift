//
//  GiftPointsViewController.swift
//  Emporium
//
//  Created by Riyfhx on 20/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie

class GiftPointsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var giftAnimationView: AnimationView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    // MARK: - Variables
    private var earnedRewardsDataManager: EarnedRewardsDataManager? = nil
    private var earnedReward: EarnedReward? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /// Set the label
        pointsLabel.text = "\(self.earnedReward?.earnedAmount ?? 0) Points"
        
        /// Set up animation
        giftAnimationView.animation = Animation.named("gift-opening-animation")
        giftAnimationView.contentMode = .scaleAspectFill
        giftAnimationView.play()
        
    }
    
    /**
        Set the Earned Rewards DataManager use for updating the 'displayed' value inside the Firebase.
            Note: Setting the DataManager is more memory friendly than to create a new DataManager
     */
    func setEarnedRewardsDataManager(dataManager: EarnedRewardsDataManager){
        self.earnedRewardsDataManager = dataManager
    }

    /**
        Set the EarnedReward variable to be displayed
     */
    func setEarnedReward(earnedReward: EarnedReward){
        self.earnedReward = earnedReward
    }
    
    @IBAction func okPressed(_ sender: Any) {
        
        //Send message to server as seen
        self.earnedRewardsDataManager?.seenEarnedRewards(self.earnedReward!, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
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
