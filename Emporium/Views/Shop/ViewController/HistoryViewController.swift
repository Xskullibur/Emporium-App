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
    
    var purchaseHistory: [String] = []
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
        
        cell.layer.cornerRadius = 10
        cell.titleLabel.text = purchaseHistory[indexPath.row]
        
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.9
        cell.layer.masksToBounds = false
        cell.clipsToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        docID = purchaseHistory[indexPath.row]
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

