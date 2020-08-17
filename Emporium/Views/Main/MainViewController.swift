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
    private var deliveryDataManager: DeliveryDataManager!
    
    private var loginManager: LoginManager!
    private var login = false
    private var loginAsUserType: UserType = .user
    
    // MARK: - Static Collection Cells
    //User Reuseable Cell Ids
    private let userCells = ["JoinQueueCell", "ShopCell", "RewardsCell"]

    //Merchant Reuseable Cell Ids
    private let merchantCells = ["CrowdTrackingCell", "StoreLocationCell"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Data Managers
        self.pointsDataManager = PointDataManager()
        self.loginManager = LoginManager(viewController: self)
        self.deliveryDataManager = DeliveryDataManager()
        
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
            
            if login && loginAsUserType == .user {
                
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
                        
                        switch (queueItem.status) {
                            
                            case .None:
                                // Navigate to NearbyMart
                                self.removeSpinner()
                                self.performSegue(withIdentifier: "ShowNearby", sender: self)
                                
                            case .InQueue:
                                // Get QueueInfo
                                queueDataManager.getQueueInfo(storeId: store.id) { (currentlyServing, queueLength) in
                                    
                                    // Check for orders
                                    self.deliveryDataManager.getDeliveryOrder { (order) in
                                        
                                        // Navigate to QueueVC
                                        DispatchQueue.main.async {
                                            self.removeSpinner()
                                            let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                                            let queueVC = queueStoryboard
                                                .instantiateViewController(identifier: "queueVC") as QueueViewController
                                            
                                            queueVC.requested = true
                                            queueVC.store = store
                                            queueVC.queueId = queueItem.id
                                            queueVC.currentlyServing = currentlyServing
                                            queueVC.queueLength = queueLength
                                            queueVC._order = order
                                            
                                            let rootVC = self.navigationController?.viewControllers.first
                                            self.navigationController?.setViewControllers([rootVC!, queueVC], animated: true)
                                        }

                                    }
                                    
                                }
                                
                            case .OnTheWay:
                                
                                // Check for Order
                                self.deliveryDataManager.getDeliveryOrder { (order) in
                                    // Navigate to Entry
                                    DispatchQueue.main.async {
                                        self.removeSpinner()
                                        let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                                        
                                        let entryVC = queueStoryboard.instantiateViewController(identifier: "entryVC") as EntryViewController
                                        entryVC.store = store
                                        entryVC.queueId = queueItem.id
                                        entryVC.order = order
                                        entryVC.requested = true
                                        
                                        let rootVC = self.navigationController?.viewControllers.first
                                        self.navigationController?.setViewControllers([rootVC!, entryVC], animated: true)
                                    }
                                }
                                
                            case .InStore:
                                
                                // Check for Order
                                self.deliveryDataManager.getDeliveryOrder { (order) in
                                    // Navigate to InStore
                                    DispatchQueue.main.async {
                                        self.removeSpinner()
                                        let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                                        let inStoreVC = queueStoryboard
                                            .instantiateViewController(identifier: "inStoreVC") as InStoreViewController
                                        inStoreVC.queueId = queueItem.id
                                        inStoreVC.store = store
                                        inStoreVC.order = order
                                        
                                        let rootVC = self.navigationController?.viewControllers.first
                                        self.navigationController?.setViewControllers([rootVC!, inStoreVC], animated: true)
                                    }
                                }
                                
                            case .Delivery:
                                
                                // Check for order
                                self.deliveryDataManager.getDeliveryOrder { (order) in
                                    
                                    if let order = order {
                                        // Navigate to Delivery
                                        DispatchQueue.main.async {
                                            self.removeSpinner()
                                            let queueStoryboard = UIStoryboard(name: "Delivery", bundle: nil)
                                            let deliveryVC = queueStoryboard
                                                .instantiateViewController(identifier: "deliveryVC") as DeliveryViewController
                                            deliveryVC.order = order
                                            deliveryVC.store = store
                                            deliveryVC.queueId = queueItem.id
                                            
                                            let rootVC = self.navigationController?.viewControllers.first
                                            self.navigationController?.setViewControllers([rootVC!, deliveryVC], animated: true)
                                        }
                                    }
                                    else {
                                        // Error Alert
                                        self.removeSpinner()
                                        let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
                                        let data = Plist.readPlist(url!)!
                                        let infoDescription = data["Error Alert"] as! String
                                        self.showAlert(title: "Oops", message: infoDescription)
                                    }
                                    
                                }
                                
                            case .Completed:
                                // Navigate to NearbyMart
                                self.removeSpinner()
                                self.performSegue(withIdentifier: "ShowNearby", sender: self)
                            
                        }
                        
                    }
                    
                }) { (error) in
                    // Error Alert
                    self.removeSpinner()
                    let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
                    let data = Plist.readPlist(url!)!
                    let infoDescription = data["Error Alert"] as! String
                    self.showAlert(title: "Oops", message: infoDescription)
                }
                
            }
            else if !login && loginAsUserType == .user {
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
