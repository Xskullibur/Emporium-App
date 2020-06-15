//
//  Cart.swift
//  Emporium
//
//  Created by user1 on 15/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class Cart: NSObject {
    
    var productID: Int
    var quantity: Int
    var productName: String
    
    init(_ id: Int, _ quantity: Int, _ name: String){
        self.productID = id
        self.quantity = quantity
        self.productName = name
    }

}
