//
//  CheckOutViewController.swift
//  Emporium
//
//  Created by user1 on 31/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Stripe

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    var cartData: [Cart] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layer.cornerRadius = 10
        priceLabel.layer.cornerRadius = 10
        
        if cartData.count == 0 {
            priceLabel.text = "Total: $0.00"
        }else{
            var total = 0.0
            for item in cartData {
                total = total + (item.price * Double(item.quantity))
            }
            priceLabel.text = "Total: $" + String(total)
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        let cartDetail = cartData[indexPath.row]
        
        cell.layer.cornerRadius = 10
        cell.nameLabel.text = cartDetail.productName
        cell.priceLabel.text = "$" + String(cartDetail.price)
        cell.quantityLabel.text = "x" + String(cartDetail.quantity)
        cell.cartImage.loadImage(url: cartDetail.image)
        
        return cell
    }
    
    
    @IBAction func PayBtnPressed(_ sender: Any) {
        
    }
    
    
    
}


