//
//  AddressTableViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 27/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class AddressTableViewController: UITableViewController {

    private var addresses: [Address] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAddresses()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadAddresses(){
        let user = Auth.auth().currentUser!
        AccountDataManager.getUserAddresses(user, completion: {
            addresses, error in
            
            guard let addresses = addresses else{
                return
            }
            self.addresses = addresses
            self.tableView.reloadData()
            
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addresses.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.addresses.count {
            //Add cell button
            let cell = tableView.dequeueReusableCell(withIdentifier: "addAddressCell", for: indexPath)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTableViewCell

            cell.setAddress(self.addresses[indexPath.row])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.addresses.count{
            let selectedAddress = self.addresses[indexPath.row]
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let addOrEditAddressViewController = storyBoard.instantiateViewController(withIdentifier: "AddOrEditAddressViewController") as! AddOrEditAddressViewController
                    
            addOrEditAddressViewController.setAddress(selectedAddress)
            self.navigationController?.pushViewController(addOrEditAddressViewController, animated: true)
        }
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
