//
//  NearbyListViewController.swift
//  Emporium
//
//  Created by Xskullibur on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class NearbyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var storeList_lessThan1: [GroceryStore] = []
    var storeList_lessThan2: [GroceryStore] = []
    var storeList_moreThan2: [GroceryStore] = []
    var tableSections = ["< 1 km", "< 2 km", "> 2 km"]
    
    weak var storeSelectDelegate: StoreSelectedDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
    }
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
            case 0:
                return storeList_lessThan1.count
            case 1:
                return storeList_lessThan2.count
            default:    // 2
                return storeList_moreThan2.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let store: GroceryStore

        switch (indexPath.section) {
            case 0:
                store = storeList_lessThan1[indexPath.row]
            case 1:
                store = storeList_lessThan2[indexPath.row]
            default:    // 2
                store = storeList_moreThan2[indexPath.row]
        }
        
        cell.textLabel?.text = store.name
        cell.detailTextLabel?.text = "\(String(format: "%.2f", store.distance)) km"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Selected GroceryStore
        let store: GroceryStore

        switch (indexPath.section) {
            case 0:
                store = storeList_lessThan1[indexPath.row]
            case 1:
                store = storeList_lessThan2[indexPath.row]
            default:    // 2
                store = storeList_moreThan2[indexPath.row]
        }
        
        // Update Selected Store
        storeSelectDelegate?.storeSelected(store: store)
        
        // Dismiss Popover
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
