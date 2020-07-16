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
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buttonsCard: MDCCard!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var mainButtonsCollectionView: UICollectionView!
    
    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    // MARK: - Variables
    private var pointsDataManager: PointDataManager!
    
    private var loginManager: LoginManager!
    private var login = false
    private var loginAsUserType: UserType = .user
    
    // MARK: - Static Collection Cells
    //User Reuseable Cell Ids
    private let userCells = ["JoinQueueCell", "ShopCell", "RewardsCell"]

    //Merchant Reuseable Cell Ids
    private let merchantCells = ["CrowdTrackingCell"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Data Managers
        self.pointsDataManager = PointDataManager()
        self.loginManager = LoginManager(viewController: self)
        
        //Setup card shadow
        buttonsCard.setShadowElevation(ShadowElevation(6), for: .normal)
        
        self.tableView = notificationTableView
        
        //Margin for the collection cell
        mainButtonsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        mainButtonsCollectionView.dataSource = self
        mainButtonsCollectionView.delegate = self
        
        //Login setup
        
        //Check if user is login
        login = Auth.auth().currentUser != nil
        
        //Update the main view if the user state change. (Example: User login or logout)
        Auth.auth().addStateDidChangeListener{
            (auth, user) in
            if let user = user {
                
                self.switchToAccountState(accountToDisplay: user)
                self.showSpinner(onView: self.view)
                
                //Get user points
                self.pointsDataManager.getPoints(user: user){
                    points in
                    self.pointsLabel.text = "\(points) Pt"
                }
                
                //Update cells based on user type
                user.getUserType{
                    userType, error in
                    self.loginAsUserType = userType!
                    self.mainButtonsCollectionView?.reloadData()
                    self.removeSpinner()
                }
            }else{
                //If user is not login
                self.switchToLoginState()
                self.loginAsUserType = .user
                self.mainButtonsCollectionView?.reloadData()
            }
            
        }
        
    }
    
    ///Change the collections cells base on user type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.loginAsUserType == .user { return userCells.count }
        else { return merchantCells.count }
    }
    
    ///Change the style of the cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //Get reuseable cells array
        var cells: [String] = userCells
        if self.loginAsUserType == .merchant {cells = merchantCells}
        
        //Get cell from reuseable id
        let cell = mainButtonsCollectionView.dequeueReusableCell(withReuseIdentifier: cells[indexPath.item], for: indexPath) as! MDCCardCollectionCell

        //Update the UI
        cell.cornerRadius = 13
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.setBorderWidth(1, for: .normal)
        cell.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        
        return cell
    }
    
    /// Collection View Selected (Join Queue)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Join Queue Cell
        if indexPath.row == 0 {
            
            if login {
                
                let queueDataManager = QueueDataManager()
                queueDataManager.checkExistingQueue(userId: Auth.auth().currentUser!.uid, onComplete: { (queueItem) in
                    
                    // Guard QueueItem
                    guard let queueItem = queueItem else {
                        // Navigate to NearbyMart
                        self.performSegue(withIdentifier: "ShowNearby", sender: self)
                        return
                    }
                    
                    // Get Store Info
                    self.showSpinner(onView: self.view)
                    
                    let storeDataManager = StoreDataManager()
                    storeDataManager.getStore(storeId: queueItem.storeId) { (store) in
                        
                        self.removeSpinner()
                        
                        switch (queueItem.status) {
                            
                            case .None:
                                // Navigate to NearbyMart
                                self.performSegue(withIdentifier: "ShowNearby", sender: self)
                                
                            case .InQueue:
                                // Navigate to QueueVC
                                let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                                let queueVC = queueStoryboard.instantiateViewController(identifier: "queueVC") as QueueViewController
                                
                                queueVC.justJoinedQueue = false
                                queueVC.store = store
                                queueVC.queueId = queueItem.id
                                
                                let rootVC = self.navigationController?.viewControllers.first
                                self.navigationController?.setViewControllers([rootVC!, queueVC], animated: true)
                                
                            case .OnTheWay:
                                // Navigate to Entry
                                let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                                
                                let entryVC = queueStoryboard.instantiateViewController(identifier: "entryVC") as EntryViewController
                                entryVC.store = store
                                entryVC.queueId = queueItem.id
                                
                                let rootVC = self.navigationController?.viewControllers.first
                                self.navigationController?.setViewControllers([rootVC!, entryVC], animated: true)
                                
                            case .InStore:
                                // Navigate to InStore
                                let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                                
                                let inStoreVC = queueStoryboard.instantiateViewController(identifier: "inStoreVC") as InStoreViewController
                                    inStoreVC.queueId = queueItem.id
                                    inStoreVC.storeId = store.id
                                
                                let rootVC = self.navigationController?.viewControllers.first
                                self.navigationController?.setViewControllers([rootVC!, inStoreVC], animated: true)
                                
                            case .Delivery:
                                // Navigate to Delivery
                                let queueStoryboard = UIStoryboard(name: "Delivery", bundle: nil)
                                
                                let confirmVC = queueStoryboard.instantiateViewController(identifier: "confirmationVC") as ConfirmationViewController
                                
                                let rootVC = self.navigationController?.viewControllers.first
                                self.navigationController?.setViewControllers([rootVC!, confirmVC], animated: true)
                                
                            case .Completed:
                                // Navigate to NearbyMart
                                self.performSegue(withIdentifier: "ShowNearby", sender: self)
                            
                        }
                        
                    }
                    
                }) { (error) in
                    // Error Alert
                    let errorAlert = UIAlertController(title: "Oops", message: "Something went wrong. Please try again later.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    errorAlert.addAction(okAction)
                    
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
            }
            else {
                // Navigate to NearbyMart
                self.performSegue(withIdentifier: "ShowNearby", sender: self)
            }
            
        }
        
    }
    
    /**
     Switch view to login state.
     */
    func switchToLoginState(){
        login = false
        
        self.menuBarButtonItem.title = "Login"
        
        //Set username back to guest
        self.nameLabel.text = "Guest"
        self.pointsLabel.text = "0 Pt"
    }
    /**
     Switch view to user state.
     - Parameters:
        - accountToDisplay: User use for displaying under the main UI view
     */
    func switchToAccountState(accountToDisplay user: User){
        login = true
        
        self.menuBarButtonItem.title = "My Account"
        
        //Set username
        self.nameLabel.text = user.displayName
    }
    
    /**
     Navigate to login or account view controller based of login state.
     */
    @IBAction func toAccountOrLoginPressed(_ sender: Any) {
        if login {
            self.performSegue(withIdentifier: "ToAccount", sender: sender)
        }else{
             self.loginManager.showLoginViewController()
        }
    }
    
}

