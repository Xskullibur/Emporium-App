//
//  SelectAddressViewController.swift
//  Emporium
//
//  Created by user1 on 13/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class SelectAddressViewController: UITableViewController {

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
        let selectedAddress = self.addresses[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addOrEditAddressViewController = storyBoard.instantiateViewController(withIdentifier: "AddOrEditAddressViewController") as! AddOrEditAddressViewController
                
        addOrEditAddressViewController.setAddress(selectedAddress)
        self.navigationController?.pushViewController(addOrEditAddressViewController, animated: true)
    }

}
