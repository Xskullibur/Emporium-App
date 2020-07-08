//
//  HistoryItem.swift
//  Emporium
//
//  Created by hsienxiang on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class HistoryItem: NSObject {
    var productID: String
    var quantity: String
    var productName: String
    var price: String
    var image: String
    
    init(_ id: String, _ quantity: String, _ name: String, _ price: String, _ image: String){
        self.productID = id
        self.quantity = quantity
        self.price = price
        self.productName = name
        self.image = image
    }
}
