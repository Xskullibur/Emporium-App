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
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var deliveryLabel: UILabel!
    
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
        
        ShopDataManager.loadHistoryDetail(docID: docID) {
            histories in
            self.cartData = histories
            
            var total = 0.0
            for history in histories {
                total = total + history.price * Double(history.quantity)
            }
            self.totalLabel.text = "$" + String(format: "%.02f", total)
            
            ShopDataManager.loadHistoryPaymentDetail(docID: self.docID) {
                Detail in
                self.receipt = Detail.receipt
                if Detail.received == "yes" {
                    self.qrCode.heightAnchor.constraint(equalToConstant: 0).isActive = true
                    self.deliveryLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
                    self.qrCode.isHidden = true
                    self.deliveryLabel.isHidden = true
                }else{
                    self.qrCode.image = QRManager.generateQRCode(from: Detail.id)
                    self.deliveryLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
                    self.qrCode.heightAnchor.constraint(equalToConstant: 240).isActive = true
                    self.qrCode.isHidden = false
                    self.deliveryLabel.isHidden = false
                }
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
        cell.priceLabel.text = "$" + String(format: "%.02f", Double(cartDetail.price))
        cell.quantityLabel.text = String(cartDetail.quantity)
        cell.cartImage.sd_setImage(with: URL(string: cartDetail.image))
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        
        return cell
    }
    
}


