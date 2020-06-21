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


    @IBOutlet weak var giftAnimationView: AnimationView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    private var earnedRewardsDataManager: EarnedRewardsDataManager? = nil
    private var earnedReward: EarnedReward? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pointsLabel.text = "\(self.earnedReward?.earnedAmount ?? 0) Points"
        
        //Set up animation
        giftAnimationView.animation = Animation.named("gift-opening-animation")
        giftAnimationView.contentMode = .scaleAspectFill
        giftAnimationView.play()
        
    }
    
    func setEarnedRewardsDataManager(dataManager: EarnedRewardsDataManager){
        self.earnedRewardsDataManager = dataManager
    }

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
