//
//  RewardSegmentedViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 16/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents

class RewardSegmentedViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var pointCard: MDCCard!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var availableView: UIView!
    @IBOutlet weak var claimedView: UIView!
    
    // MARK: - Variables
    private var pointDataManager: PointDataManager? = nil
    
    private var user: User!
    private var loginManager: LoginManager? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.loginManager = LoginManager(viewController: self)
        
        //Setup card shadow
        pointCard.setShadowElevation(ShadowElevation(6), for: .normal)
        
        if let user = Auth.auth().currentUser {
            self.user = user
            self.setupPoints()
        }else{
            self.loginManager?.setLoginComplete{
                user in
                
                guard let user = user else {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                self.user = user
                self.setupPoints()
            }
            
            self.loginManager?.showLoginViewController()
        }
    }
    
    /**
     Setup the Point Data Manager
     */
    func setupPoints(){
        self.pointDataManager = PointDataManager()
        self.pointDataManager?.getPoints(user: self.user){
            points in
            self.pointsLabel.text = "\(points) Pt"
        }
    }
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            headerLabel.text = "Available Vouchers"
            availableView.alpha = 1
            claimedView.alpha = 0
        }else{
            headerLabel.text = "Claimed Vouchers"
            availableView.alpha = 0
            claimedView.alpha = 1
        }
    }
    
    @IBAction func onPointInfoTap(_ sender: Any) {
        //Show point info
        let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
        let data = Plist.readPlist(url!)!
        let infoDescription = data["Points Info Description"] as! String
        self.showAlert(title: "Info", message: infoDescription)
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
