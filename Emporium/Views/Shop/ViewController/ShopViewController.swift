//
//  ShopViewController.swift
//  Emporium
//
//  Created by user1 on 31/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards

class ShopViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cartCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var ProductCateLabel: UILabel!
    
    var productData: [Product] = []
    var cartData: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.placeholder = "Search Products"
        
        loadProducts()
        
        searchBtn.layer.cornerRadius = 5
        
        self.collectionView.layer.cornerRadius = 10
        self.cartCollectionView.layer.cornerRadius = 10
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.cartCollectionView.dataSource = self
        self.cartCollectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "ProductViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductViewCell")
        self.cartCollectionView.register(UINib(nibName: "SideCartCell", bundle: nil), forCellWithReuseIdentifier: "SideCartCell")
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
    
    func searchProducts(search: String) {
        var sortedList: [Product] = []
        
        ShopDataManager.loadProducts() {
            productList in
            for product in productList {
                if product.productName.lowercased().contains(search.lowercased()) {
                    sortedList.append(product)
                }
            }
            self.ProductCateLabel.text = "Product: tap to add (result for " + search + ")"
            self.productData = sortedList
            self.collectionView.reloadData()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        DispatchQueue.main.async {
            self.cartCollectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.cartData.count == 0 {
            showToast("Cart is empty")
        }
        let destVC = segue.destination as! CheckOutViewController
        destVC.cartData = self.cartData
    }
    
    func showToast(_ message: String) {
        guard let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first else {
            return
        }
        
        let toastLbl = UILabel()
        toastLbl.text = message
        toastLbl.textAlignment = .center
        toastLbl.font = UIFont.systemFont(ofSize: 18)
        toastLbl.textColor = UIColor.white
        toastLbl.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLbl.numberOfLines = 0
        
        
        let textSize = toastLbl.intrinsicContentSize
        let labelHeight = ( textSize.width / window.frame.width ) * 30
        let labelWidth = min(textSize.width, window.frame.width - 40)
        let adjustedHeight = max(labelHeight, textSize.height + 20)
        
        toastLbl.frame = CGRect(x: 20, y: (window.frame.height - 90 ) - adjustedHeight, width: labelWidth + 20, height: adjustedHeight)
        toastLbl.center.x = window.center.x
        toastLbl.layer.cornerRadius = 10
        toastLbl.layer.masksToBounds = true
        
        window.addSubview(toastLbl)
        
        UIView.animate(withDuration: 3.0, animations: {
            toastLbl.alpha = 0
        }) { (_) in
            toastLbl.removeFromSuperview()
        }
    }
    
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        if searchTextField.text == "" {
            loadProducts()
        }else{
            searchProducts(search: searchTextField.text!)
        }
    }
}

extension ShopViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.collectionView) {
            return self.productData.count
        }else{
            return self.cartData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductViewCell", for: indexPath) as! ProductViewCell
            cell.setCell(name: self.productData[indexPath.row].productName, price: String(self.productData[indexPath.row].price), image: self.productData[indexPath.row].image)
            
            cell.cornerRadius = 13
            cell.contentView.layer.masksToBounds = true
            cell.clipsToBounds = true
            cell.setBorderWidth(1, for: .normal)
            cell.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
            cell.layer.masksToBounds = false
            cell.setShadowElevation(ShadowElevation(6), for: .normal)
            return cell
        }else{
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "SideCartCell", for: indexPath) as! SideCartCell
            cell2.setCell(self.cartData[indexPath.row].productName, self.cartData[indexPath.row].quantity, self.cartData[indexPath.row].image)
            //self.cartData[indexPath.row].image
            //"noImage"
            cell2.cornerRadius = 13
            cell2.contentView.layer.masksToBounds = true
            cell2.clipsToBounds = true
            cell2.setBorderWidth(1, for: .normal)
            cell2.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
            cell2.layer.masksToBounds = false
            cell2.setShadowElevation(ShadowElevation(6), for: .normal)
            return cell2
        }
    }
}

extension ShopViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: 140, height: 200)
        }else{
            return CGSize(width: 150, height: 50)
        }
        
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
                    showToast(String(name) + " added, quantity: " + String(cartItem.quantity))
                    newItem = false
                    DispatchQueue.main.async {
                        self.cartCollectionView.reloadData()
                    }
                    
                    return
                }
            }
            
            if newItem == true {
                cartData.append(Cart(id, 1, name, price, image))
                showToast(String(name) + " added")
                DispatchQueue.main.async {
                    self.cartCollectionView.reloadData()
                }
            }
            
        }else{
            if cartData[indexPath.row].quantity > 1 {
                cartData[indexPath.row].quantity = cartData[indexPath.row].quantity - 1
                showToast(String(cartData[indexPath.row].productName) + " removed, quantity: " + String(cartData[indexPath.row].quantity))
                DispatchQueue.main.async {
                    self.cartCollectionView.reloadData()
                }
            }else{
                cartData.remove(at: indexPath.row)
                showToast("item removed")
                DispatchQueue.main.async {
                    self.cartCollectionView.reloadData()
                }
            }
        }
        
        
    }
}



