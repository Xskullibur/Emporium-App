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
    
    init(_ id: Int, _ quantity: Int){
        self.productID = id
        self.quantity = quantity
    }

}
