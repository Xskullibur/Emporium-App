//
//  ShoppingListViewController.swift
//  Emporium
//
//  Created by hsienxiang on 31/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var delegate: DataDelegate?
    var cartData: [Cart] = []
    var itemList: [ShoppingList] = []
    var listName: [String] = []
    var productData: [Product] = []
    
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
        addListToCart(name: listName[indexPath.row])
    }
    
    func addListToCart(name: String) {
        ShopDataManager.loadShoppingListItems(name: name) {
            item in
            self.itemList = item
            
            for item in self.itemList
            {
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
            }
            print(self.cartData.count)
            self.delegate?.setCartData(cartData: self.cartData)
        }
    }
}

extension ShoppingListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? ShopViewController)?.cartData = self.cartData
    }
}
