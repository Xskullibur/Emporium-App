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

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShopListDelegate, VoucherDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var toPaymentBtn: UIButton!
    @IBOutlet weak var addItemBtn: UIButton!
    
    var cartData: [Cart] = []
    var voucher: Voucher? = nil
    var listName: String = ""
    
    //from shoplist
    var productData: [Product] = []
    //from shoplist
   
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
            loadProducts()
            toPaymentBtn.isHidden = true
            self.title = self.listName
            self.addItemBtn.setTitle("Add Item", for: .normal)
        }else{
            toPaymentBtn.isHidden = false
            self.title = "Order"
            self.addItemBtn.setTitle("Use Voucher", for: .normal)
        }
    }
    
    func loadProducts() {
        ShopDataManager.loadProducts() {
            productList in
            self.productData = productList
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
    
    func setVoucher(voucher: Voucher) {
        self.voucher = voucher
        print("voucher added")
    }
    
    func setListCartData(newCartData: Cart) {
        
        let item = newCartData
        var found = false
        for cart in self.cartData
        {
            if cart.productID == item.productID
            {
                cart.quantity = cart.quantity + Int(item.quantity)
                found = true
                break
            }
        }
        
        if found == false
        {
            for product in self.productData
            {
                if product.id == item.productID
                {
                    self.cartData.append(Cart(product.id, item.quantity, product.productName, product.price, product.image))
                    break
                }
            }
        }
        
        
        //self.cartData = cartData
        self.tableView.reloadData()
        print("updated")
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
                //showActionSheet(sender as! UIView)
                self.performSegue(withIdentifier: "toAddress", sender: nil)
            }
        }
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if(!fromShop()) {
            self.editShoppingList(name: listName)
        }else{
            saveActionSheet()
        }
    }
    
    
    @IBAction func addItemBtnPressed(_ sender: Any) {
        if(!fromShop()) {
            let baseSB = UIStoryboard(name: "Shop", bundle: nil)
            let vc = baseSB.instantiateViewController(identifier: "ShopVC") as! ShopViewController
            vc.listName = self.listName
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let baseSB = UIStoryboard(name: "Shop", bundle: nil)
            let vc = baseSB.instantiateViewController(identifier: "voucherVC") as! VoucherTableViewController
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGateway" {
            let destVC = segue.destination as! GatewayViewController
            destVC.cartData = self.cartData
        }else if segue.identifier == "toCard" {
            let destVC = segue.destination as! DisplayCardViewController
            destVC.cartData = self.cartData
        }else if segue.identifier == "toAddress" {
            let destVC = segue.destination as! SelectAddressViewController
            destVC.cartData = self.cartData
            destVC.voucher = self.voucher
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
    
    func editShoppingList(name: String) {
        var sList : [String] = []
        for cart in cartData {
            sList.append(cart.productID)
            sList.append(String(cart.quantity))
        }
        ShopDataManager.editShoppingList(list: sList, name: name)
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

protocol ShopListDelegate {
    func setListCartData(newCartData: Cart)
}

protocol VoucherDelegate {
    func setVoucher(voucher: Voucher)
}

