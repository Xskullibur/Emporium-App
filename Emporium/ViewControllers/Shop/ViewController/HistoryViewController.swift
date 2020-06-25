//
//  HistoryViewController.swift
//  Emporium
//
//  Created by user1 on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var purchaseHistory: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHistory()
        tableView.layer.cornerRadius = 10
        
    }
    
    func loadHistory() {
        ShopDataManager.loadHistory() {
            history in
            self.purchaseHistory = history
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        
        cell.layer.cornerRadius = 10
        cell.titleLabel.text = purchaseHistory[indexPath.row]
        
        return cell
    }
    
}
