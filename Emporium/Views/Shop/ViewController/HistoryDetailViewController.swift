//
//  HistoryDetailViewController.swift
//  Emporium
//
//  Created by hsienxiang on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    var docID: String = ""
    var cartData: [HistoryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        
        totalLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        totalLabel.layer.shadowColor = UIColor.darkGray.cgColor
        totalLabel.layer.shadowRadius = 5
        totalLabel.layer.shadowOpacity = 0.9
        totalLabel.layer.masksToBounds = false
        totalLabel.clipsToBounds = false

        loadHistoryDetail()
    }
    
    func loadHistoryDetail() {
        var rawCart: [String] = []
        var total: Double = 0.0
        
        ShopDataManager.loadHistoryDetail(docID: docID) {
            cartDetail in
            rawCart = cartDetail
            
            for i in stride(from: 0, to: rawCart.count - 1, by: 5) {
                
                let productID = rawCart[i]
                let quantity = rawCart[i+1]
                let name = rawCart[i+2]
                let price = rawCart[i+3]
                let image = rawCart[i+4]
                
                //total = total + (Double(quantity!)*Double(price!))
                self.cartData.append(HistoryItem(productID, quantity, name, price, image))
                total = total + (Double(price)! * Double(quantity)!)
            }
            self.totalLabel.text = "Total: $" + String(format: "%.02f", total)
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCartCell", for: indexPath) as! HistoryCartCell
        let cartDetail = cartData[indexPath.row]
        
        cell.layer.cornerRadius = 10
        cell.nameLabel.text = cartDetail.productName
        cell.priceLabel.text = "$" + String(format: "%.02f", Double(cartDetail.price)!)
        cell.quantityLabel.text = cartDetail.quantity
        cell.cartImage.loadImage(url: cartDetail.image)
        
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.9
        cell.layer.masksToBounds = false
        cell.clipsToBounds = false
        
        return cell
    }
    
}
