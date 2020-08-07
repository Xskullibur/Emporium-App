//
//  ShoppingListViewController.swift
//  Emporium
//
//  Created by hsienxiang on 31/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var delegate: DataDelegate?
    var cartData: [Cart] = []
    var itemList: [ShoppingList] = []
    var listName: [String] = []
    var productData: [Product] = []
    
    var editCartData: [Cart] = []
    
    var passListName: String = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        loadList()
        loadProducts()
    }
    
    func loadList() {
        ShopDataManager.loadShoppingList() {
            name in
            self.listName = name
            self.tableview.reloadData()
        }
    }
    
    func loadProducts() {
        ShopDataManager.loadProducts() {
            productList in
            self.productData = productList
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = listName[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActionSheet(row: indexPath.row)
    }
    
    func addListToCart(name: String) {
        ShopDataManager.loadShoppingListItems(name: name) {
            item in
            self.itemList = item
            for item in self.itemList
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
            self.delegate?.setCartData(newCartData: self.cartData)
        }
    }
    
    func editListToCart(name: String) {
        self.editCartData = []
        ShopDataManager.loadShoppingListItems(name: name) {
            item in
            self.itemList = item
            for item in self.itemList
            {
                for product in self.productData
                {
                    if product.id == item.productID
                    {
                        self.editCartData.append(Cart(product.id, item.quantity, product.productName, product.price, product.image))
                        break
                    }
                }
            }
            self.performSegue(withIdentifier: "toEdit", sender: nil)
        }
    }
    
    func showActionSheet(row: Int) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addList = UIAlertAction(title: "Add To Cart", style: .default) {
            action in
            self.addListToCart(name: self.listName[row])
        }
        
        let editList = UIAlertAction(title: "View/Edit", style: .default) {
            action in
            self.passListName = self.listName[row]
            self.editListToCart(name: self.listName[row])
        }
        
        let deleteList = UIAlertAction(title: "Delete List", style: .default) {
            action in
            self.deleteShoppingList(name: self.listName[row])
        }
        
        actionSheet.addAction(addList)
        actionSheet.addAction(editList)
        actionSheet.addAction(deleteList)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func deleteShoppingList(name: String) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("shopping_list").document(name).delete() {
            err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                self.loadList()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            let destVC = segue.destination as! CheckOutViewController
            destVC.cartData = self.editCartData
            destVC.listName = self.passListName
        }
    }
}

extension ShoppingListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? ShopViewController)?.cartData = self.cartData
    }
}
