//
//  CheckOutViewController.swift
//  Emporium
//
//  Created by user1 on 31/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    var cartData: [Cart] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layer.cornerRadius = 10
        priceLabel.layer.cornerRadius = 10
        
        priceLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        priceLabel.layer.shadowColor = UIColor.darkGray.cgColor
        priceLabel.layer.shadowRadius = 5
        priceLabel.layer.shadowOpacity = 0.9
        priceLabel.layer.masksToBounds = false
        priceLabel.clipsToBounds = false
        
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
        cell.priceLabel.text = "Price: $" + String(cartDetail.price)
        cell.quantityLabel.text = "Quantity: " + String(cartDetail.quantity)
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
    
    
    @IBAction func PayBtnPressed(_ sender: Any) {
        if self.cartData.count == 0 {
            Toast.showToast("Cart is empty select something first!")
        }else{
            if Auth.auth().currentUser?.uid == nil {
                Toast.showToast("You need to log in to make purchase!")
            }else{
                //performSegue(withIdentifier: "toGateway", sender: nil)
                showActionSheet()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGateway" {
            let destVC = segue.destination as! GatewayViewController
            destVC.cartData = self.cartData
        }
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let card = UIAlertAction(title: "Select Card", style: .default) {
            action in
            self.performSegue(withIdentifier: "toCard", sender: nil)
        }
        
        let payment = UIAlertAction(title: "One Time Payment", style: .default) {
            action in
            self.performSegue(withIdentifier: "toGateway", sender: nil)
        }
        
        actionSheet.addAction(card)
        actionSheet.addAction(payment)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}


