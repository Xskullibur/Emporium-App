//
//  CheckOutViewController.swift
//  Emporium
//
//  Created by hsienxiang on 31/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var toPaymentBtn: UIButton!
    
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
            priceLabel.text = "Total: $" + String(format: "%.02f", total)
        }
        
        if(!fromShop()) {
            toPaymentBtn.isHidden = true
            priceLabel.isHidden = true
        }else{
            toPaymentBtn.isHidden = false
            priceLabel.isHidden = false
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
        cell.priceLabel.text = "$" + String(format: "%.02f", cartDetail.price)
        cell.quantityLabel.text = String(cartDetail.quantity)
        cell.cartImage.sd_setImage(with: URL(string: cartDetail.image))
        
        cell.stepper.tag = indexPath.row
        cell.stepper.value = Double(cartDetail.quantity)
        cell.stepper.addTarget(self, action: #selector(changeQuantity(sender:)), for: .valueChanged)
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        
        return cell
    }
    
    @objc func changeQuantity(sender: UIStepper) {
        let selectedItem = cartData[sender.tag]
        selectedItem.quantity = Int(sender.value)
        
        if selectedItem.quantity == 0 {
            cartData.remove(at: sender.tag)
            Toast.showToast("Item is removed")
        }
        
        var total = 0.0
        for item in cartData {
            total = total + (item.price * Double(item.quantity))
        }
        priceLabel.text = "Total: $" + String(format: "%.02f", total)
        tableView.reloadData()
    }
    
    @IBAction func PayBtnPressed(_ sender: Any) {
        if self.cartData.count == 0 {
            Toast.showToast("Cart is empty select something first!")
        }else{
            if Auth.auth().currentUser?.uid == nil {
                Toast.showToast("You need to log in to make purchase!")
            }else{
                showActionSheet(sender as! UIView)
            }
        }
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        saveActionSheet()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGateway" {
            let destVC = segue.destination as! GatewayViewController
            destVC.cartData = self.cartData
        }else if segue.identifier == "toCard" {
            let destVC = segue.destination as! DisplayCardViewController
            destVC.cartData = self.cartData
        }
    }
    
    func showActionSheet(_ sender: UIView) {
        
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
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func saveActionSheet() {
        if cartData.count > 0 {
            let actionSheet = UIAlertController(title: "Give it a name!", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let save = UIAlertAction(title: "Save", style: .default) {
                action in
                let name = actionSheet.textFields![0]
                if name.text != "" {
                    self.createShoppingList(name: name.text!)
                }
            }
            
            actionSheet.addAction(save)
            actionSheet.addAction(cancel)
            actionSheet.addTextField()
            
            present(actionSheet, animated: true, completion: nil)
        }else{
            Toast.showToast("Cart is empty select something first!")
        }
    }
    
    func createShoppingList(name: String) {
        var sList : [String] = []
        for cart in cartData {
            sList.append(cart.productID)
            sList.append(String(cart.quantity))
        }
        ShopDataManager.addShoppingList(list: sList, name: name)
    }
    
    func fromShop() -> Bool {
        if let vcs = self.navigationController?.viewControllers {
            let previousVC = vcs[vcs.count - 2]
            if previousVC is ShoppingListViewController {
                return false
            }else{
                return true
            }
        }
        return true
    }
    
}

extension CheckOutViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? ShopViewController)?.cartData = cartData
    }
}


