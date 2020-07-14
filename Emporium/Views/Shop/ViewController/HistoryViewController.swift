//
//  HistoryViewController.swift
//  Emporium
//
//  Created by hsienxiang on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var purchaseHistory: [History] = []
    var docID: String = ""
    
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
        let history = purchaseHistory[indexPath.row]
        var total: Double = 0.0
        total = Double(history.amount)! / 100.0
        
        cell.layer.cornerRadius = 10
        cell.titleLabel.text = history.date
        cell.totalLabel.text = "$" + String(format: "%.02f", total)
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        
        if history.received == "no" {
            cell.receivedLabel.text = "No"
            cell.receivedLabel.textColor = .red
        }else{
            cell.receivedLabel.text = "Yes"
            cell.receivedLabel.textColor = .green
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        docID = purchaseHistory[indexPath.row].date
        showActionSheet()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! HistoryDetailViewController
        destVC.docID = self.docID
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let showCart = UIAlertAction(title: "Show Cart", style: .default) {
            action in
            self.performSegue(withIdentifier: "showDetail", sender: nil)
        }
        
        actionSheet.addAction(showCart)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

