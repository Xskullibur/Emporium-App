//
//  GroceryStoresTableViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 29/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import FirebaseAuth

class GroceryStoresTableViewController: UITableViewController {

    // MARK: - Variables
    private var storeDataManager: StoreDataManager!
    private var crowdTrackingDataManager: CrowdTrackingDataManager!
    private var groceryStores: [GroceryStore] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let uid = Auth.auth().currentUser!.uid
        
        self.storeDataManager = StoreDataManager()
        self.storeDataManager.getStoreByMerchantId(uid, onComplete: { (groceryStores) in
            
            //Update table view when there are results from data manager
            self.groceryStores = groceryStores
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groceryStores.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryStoreCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = groceryStores[indexPath.row].name
        cell.detailTextLabel?.text = groceryStores[indexPath.row].address
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the grocery store
        let groceryStore = groceryStores[indexPath.row]
        
        let crowdTrackingViewController = storyboard?.instantiateViewController(identifier: "CrowdTrackingViewController") as! CrowdTrackingViewController
        crowdTrackingViewController.groceryStoreId = groceryStore.id
        
        //Show view controller
        self.navigationController?.pushViewController(crowdTrackingViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
