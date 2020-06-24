//
//  HistoryDetailViewController.swift
//  Emporium
//
//  Created by user1 on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    
    var docID: String = ""
    var cartData: [HistoryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadHistoryDetail()
    }
    
    func loadHistoryDetail() {
        var rawCart: [String] = []
        
        ShopDataManager.loadHistoryDetail(docID: docID) {
            cartDetail in
            rawCart = cartDetail
            
            for i in stride(from: 0, to: rawCart.count - 1, by: 5) {
                
                let productID = rawCart[i]
                let quantity = rawCart[i+1]
                let name = rawCart[i+2]
                let price = rawCart[i+3]
                let image = rawCart[i+4]
                
                self.cartData.append(HistoryItem(productID, quantity, name, price, image))
            }
            print(rawCart)
        }
    }
}
