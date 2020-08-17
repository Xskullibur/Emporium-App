//
//  ShopViewController.swift
//  Emporium
//
//  Created by hsienxiang on 31/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards
import RSSelectionMenu

class ShopViewController: UIViewController, DataDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var ProductCateLabel: UILabel!
    
    
    @IBOutlet weak var shopListBtn: UIButton!
    @IBOutlet weak var cartBtn: UIBarButtonItem!
    
    var productData: [Product] = []
    var cartData: [Cart] = []
    let category: [String] = ["Snack", "Beverage", "Dairy", "Meat", "Dry Goods", "Canned", "Produce"]
    var selectedCategory: [String] = []
    
    var delegate: ShopListDelegate?
    var listName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.placeholder = "Search Products"
        
        loadProducts()
        
        searchBtn.layer.cornerRadius = 5
        
        self.collectionView.layer.cornerRadius = 10
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "ProductViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductViewCell")
        
        
        
        if(self.fromShopList()) {
            self.cartBtn.isEnabled = false
            self.shopListBtn.isHidden = true
            self.title = "Add Item (\(self.listName))"
            self.ProductCateLabel.text = "You are adding items to (\(self.listName))"
            self.ProductCateLabel.textColor = .systemBlue
        }else{
            self.cartBtn.isEnabled = true
            self.shopListBtn.isHidden = false
            self.ProductCateLabel.text = "Product: tap to add"
        }
    }
    
    func loadProducts() {
        self.showSpinner(onView: self.view)
        ShopDataManager.loadProducts() {
            productList in
            
            self.productData = productList
            self.collectionView.reloadData()
            self.removeSpinner()
        }
    }
    
    func loadCategory() {
        self.showSpinner(onView: self.view)
        ShopDataManager.loadCategory(selectedCategory: selectedCategory) {
            productList in
            
            self.productData = productList
            //self.ProductCateLabel.text = "Product: tap to add"
            self.collectionView.reloadData()
            self.removeSpinner()
        }
    }
    
    func searchProducts(search: String) {
        var sortedList: [Product] = []
        
        ShopDataManager.loadProducts() {
            productList in
            for product in productList {
                if self.selectedCategory.count != 0 && self.selectedCategory.contains(product.category) {
                    if product.productName.lowercased().contains(search.lowercased()) {
                        sortedList.append(product)
                    }
                }else if self.selectedCategory.count == 0 {
                    if product.productName.lowercased().contains(search.lowercased()) {
                        sortedList.append(product)
                    }
                }
            }
            self.ProductCateLabel.text = "Product: tap to add (result for " + search + ")"
            self.productData = sortedList
            self.collectionView.reloadData()
        }
    }
    
    func showFilter() {
        let selectionMenu = RSSelectionMenu(selectionStyle: .multiple, dataSource: category)  {
            (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.show(style: .actionSheet(title: "Category", action: "Filter", height: nil), from: self)
        
        
        selectionMenu.onDismiss = { [weak self] selectedItems in
            self?.selectedCategory = []
            self?.selectedCategory = selectedItems
            
            if self?.selectedCategory.count == 0 {
                self?.loadProducts()
            }else{
                self?.loadCategory()
            }
        }
        
        selectionMenu.setSelectedItems(items: selectedCategory) { [weak self] (item, index, isSelected, selectedItems) in
            self?.selectedCategory = selectedItems
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.cartData.count == 0 {
            Toast.showToast("Cart is empty")
        }else{
            var toDelete: [Int] = []
            for index in 0..<cartData.count {
                if cartData[index].quantity < 1 {
                    toDelete.append(index)
                }
            }
            for index in toDelete {
                cartData.remove(at: index)
            }
        }
        if segue.identifier == "toCheckOut" {
            let destVC = segue.destination as! CheckOutViewController
            destVC.cartData = self.cartData
        }else if segue.identifier == "toShoppingList" {
            let destVC = segue.destination as! ShoppingListViewController
            destVC.cartData = self.cartData
            let vc = ShoppingListViewController()
            vc.delegate = self
        }
        
    }
    
    func setCartData(newCartData: [Cart]) {
        
        for item in newCartData
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
        
        //self.cartData = cartData
        print("received")
    }
    
    func fromShopList() -> Bool {
        if let vcs = self.navigationController?.viewControllers {
            let previousVC = vcs[vcs.count - 2]
            if previousVC is CheckOutViewController {
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        if searchTextField.text == "" {
            loadProducts()
        }else{
            searchProducts(search: searchTextField.text!)
        }
    }
    
    @IBAction func filterBtnPressed(_ sender: Any) {
        showFilter()
    }
    
    
    @IBAction func cartBtnPressed(_ sender: Any) {
        Payment.getOrderExist(onComplete: { (exist) in
            if(exist){
                //if order exist
                let showAlert = UIAlertController(title: "Alert", message: "You have already have a exising order", preferredStyle: .alert)
                let back = UIAlertAction(title: "OK", style: .default) {
                    action in
                    let baseSB = UIStoryboard(name: "Shop", bundle: nil)
                    let vc = baseSB.instantiateViewController(identifier: "HistoryViewController") as! HistoryViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                showAlert.addAction(back)
                self.present(showAlert, animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "toCheckOut", sender: nil)
                
            }
        })
        
    }
    
    
    @IBAction func toShopList(_ sender: Any) {
        if(fromShopList()){
            //self.delegate?.setListCartData(newCartData: cartData)
        }else{
            let baseSB = UIStoryboard(name: "Shop", bundle: nil)
            let vc = baseSB.instantiateViewController(identifier: "ShopListVC") as! ShoppingListViewController
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension ShopViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductViewCell", for: indexPath) as! ProductViewCell
        let product = productData[indexPath.row]
        cell.setCell(name: product.productName, price: String(format: "%.02f", product.price), image: product.image)
        
        if(fromShopList()) {
            cell.setColorPurple()
        }else{
            
        }
        
        cell.cornerRadius = 13
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.setBorderWidth(1, for: .normal)
        cell.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cell.layer.masksToBounds = false
        cell.setShadowElevation(ShadowElevation(1), for: .normal)
        return cell
    }
}

extension ShopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: 170, height: 220)
    }
}

extension ShopViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            let id = self.productData[indexPath.row].id
            let name = self.productData[indexPath.row].productName
            let price = self.productData[indexPath.row].price
            let image = self.productData[indexPath.row].image
            var newItem = true
            
            if(fromShopList()) {//from shoplist
               self.delegate?.setListCartData(newCartData: Cart(id, 1, name, price, image))
            }else{//default
                for cartItem in cartData {
                    if cartItem.productID == id {
                        cartItem.quantity = cartItem.quantity + 1
                        Toast.showToast(String(name) + " added, quantity: " + String(cartItem.quantity))
                        newItem = false
                        return
                    }
                }
                
                if newItem == true {
                    cartData.append(Cart(id, 1, name, price, image))
                    Toast.showToast(String(name) + " added")
                }
            }
            
            
            
        }else{
            
        }
    }
}

protocol DataDelegate {
    func setCartData(newCartData: [Cart])
}

