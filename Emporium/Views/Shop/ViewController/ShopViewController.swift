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

class ShopViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var ProductCateLabel: UILabel!
    
    
    var productData: [Product] = []
    var cartData: [Cart] = []
    let category: [String] = ["Snack", "Beverage", "Dairy", "Meat", "Dry Goods", "Canned", "Produce"]
    var selectedCategory: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.placeholder = "Search Products"
        
        loadProducts()
        
        searchBtn.layer.cornerRadius = 5
        
        self.collectionView.layer.cornerRadius = 10
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        self.collectionView.register(UINib(nibName: "ProductViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductViewCell")
    }
    
    func loadProducts() {
        self.showSpinner(onView: self.view)
        ShopDataManager.loadProducts() {
            productList in
            
            self.productData = productList
            self.ProductCateLabel.text = "Product: tap to add"
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
        
        let destVC = segue.destination as! CheckOutViewController
        destVC.cartData = self.cartData
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
    
}

extension ShopViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductViewCell", for: indexPath) as! ProductViewCell
        let product = productData[indexPath.row]
        cell.setCell(name: product.productName, price: String(format: "%.02f", product.price), image: product.image)
        
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
            
        }else{
            
        }
    }
}



