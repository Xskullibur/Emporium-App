//
//  HistoryDetailViewController.swift
//  Emporium
//
//  Created by hsienxiang on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import WebKit
import SDWebImage

class HistoryDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var last4Label: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    var docID: String = ""
    var cartData: [HistoryItem] = []
    var receipt: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10

        loadHistoryDetail()
    }
    
    
    @IBAction func showBtnPressed(_ sender: Any) {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(webView)
        let url = URL(string: self.receipt)
        webView.load(URLRequest(url: url!))
    }
    
    func loadHistoryDetail() {
        var rawCart: [String] = []
        var total: Double = 0.0
        
        ShopDataManager.loadHistoryDetail(docID: docID) {
            cartDetail in
            //rawCart = cartDetail
            
            for i in stride(from: 0, to: rawCart.count - 1, by: 5) {

                let productID = rawCart[i]
                let quantity = rawCart[i+1]
                let name = rawCart[i+2]
                let price = rawCart[i+3]
                let image = rawCart[i+4]

                self.cartData.append(HistoryItem(productID, quantity, name, price, image))
                total = total + (Double(price)! * Double(quantity)!)
            }
            
//            for item in cartDetail {
//                let productID = item.get
//            }
//
            self.totalLabel.text = "$" + String(format: "%.02f", total)
            
            ShopDataManager.loadHistoryPaymentDetail(docID: self.docID) {
                Detail in
                self.typeLabel.text = Detail.brand.capitalizingFirstLetter() + " " + Detail.type.capitalizingFirstLetter()
                self.last4Label.text = "(*" + Detail.last4 + ")"
                self.receipt = Detail.receipt
            }
            
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
        cell.cartImage.sd_setImage(with: URL(string: cartDetail.image))
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        
        return cell
    }
    
}


