//
//  ViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 19/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Combine
import MaterialComponents.MaterialCards
import Firebase

class MainViewController: EmporiumNotificationViewController,
UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var mainButtonsCollectionView: UICollectionView!
    
    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    var login = false
    
    var loginAsUserType: UserType = .user
    
    //User Cells
    let userCells = ["JoinQueueCell", "ShopCell", "RewardsCell"]

    //Merchant Cells
    let merchantCells = ["CrowdTrackingCell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableView = notificationTableView
        
        mainButtonsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        mainButtonsCollectionView.dataSource = self
        mainButtonsCollectionView.delegate = self
        
        login = Auth.auth().currentUser != nil
        
        Auth.auth().addStateDidChangeListener{
            (auth, user) in
            if let user = user {
                self.switchToAccountState(accountToDisplay: user)
                
                //Update cells based on user type
                self.showSpinner(onView: self.view)
                user.getUserType{
                    userType, error in
                    self.loginAsUserType = userType!
                    self.mainButtonsCollectionView?.reloadData()
                    self.removeSpinner()
                }
            }else{
                self.switchToLoginState()
                self.loginAsUserType = .user
                self.mainButtonsCollectionView?.reloadData()
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.loginAsUserType == .user { return userCells.count }
        else { return merchantCells.count }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var cells: [String] = userCells
        if self.loginAsUserType == .merchant {cells = merchantCells}
        
        let cell = mainButtonsCollectionView.dequeueReusableCell(withReuseIdentifier: cells[indexPath.item], for: indexPath) as! MDCCardCollectionCell

        cell.cornerRadius = 13
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.setBorderWidth(1, for: .normal)
        cell.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cell.layer.masksToBounds = false
        cell.setShadowElevation(ShadowElevation(6), for: .normal)
        
        return cell
    }
    
    func switchToLoginState(){
        login = false
        
        self.menuBarButtonItem.title = "Login"
    }
    func switchToAccountState(accountToDisplay user: User){
        login = true
        
        self.menuBarButtonItem.title = "My Account"
        
    }
    
    @IBAction func toAccountOrLoginPressed(_ sender: Any) {
        if login {
            self.performSegue(withIdentifier: "ToAccount", sender: sender)
        }else{
            self.performSegue(withIdentifier: "ToLogin", sender: sender)
        }
    }
    
}

