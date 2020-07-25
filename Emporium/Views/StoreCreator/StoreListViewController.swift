//
//  StoreListViewController.swift
//  Emporium
//
//  Created by ITP312Grp1 on 20/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import FirebaseAuth

class StoreListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variable
    var storeList: [GroceryStore] = []
    var merchantId: String?
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStores()
    }

    override func viewDidAppear(_ animated: Bool) {
        loadStores()
    }
    
    // MARK: - Custom Functions
    func loadStores() {
        // Get UserId
        merchantId = Auth.auth().currentUser?.uid
        
        // Get Merchant Stores
        showSpinner(onView: self.view)
        let storeDataManager = StoreDataManager()
        storeDataManager.getStoreByMerchantId(merchantId!, onComplete: { (storeList) -> Void in
            self.storeList = storeList
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            self.removeSpinner()
            
        }, onError: { (error) -> Void in
            print("Error getting merchant stores \(error)")
        })
    }
    
    // MARK: - TableViews
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if storeList.count == 0 {
            tableView.setEmptyMessage("No Store Found...")
        }
        else {
            tableView.restore()
        }
        return storeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = storeList[indexPath.row].name
        cell.detailTextLabel?.text = storeList[indexPath.row].address
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
