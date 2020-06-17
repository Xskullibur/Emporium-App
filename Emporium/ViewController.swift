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

class ViewController: EmporiumNotificationViewController,
UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var mainButtonsCollectionView: UICollectionView!
    
    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    var login = false
    
    let cells = ["CrowdTrackingCell", "ShopCell", "RewardsCell"]
    
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
            }else{
                self.switchToLoginState()
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

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

