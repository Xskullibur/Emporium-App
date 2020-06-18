//
//  Cart.swift
//  Emporium
//
//  Created by user1 on 15/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class Cart: NSObject {
    
    var productID: String
    var quantity: Int
    var productName: String
    var price: Double
    var image: String
    
    init(_ id: String, _ quantity: Int, _ name: String, _ price: Double, _ image: String){
        self.productID = id
        self.quantity = quantity
        self.price = price
        self.productName = name
        self.image = image
    }

}
