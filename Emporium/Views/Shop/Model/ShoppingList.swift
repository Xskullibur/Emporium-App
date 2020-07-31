//
//  ShoppingList.swift
//  Emporium
//
//  Created by user1 on 31/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class ShoppingList: NSObject {
    var productID: String
    var quantity: Int
    
    init(id: String, quan: Int) {
        self.productID = id
        self.quantity = quan
    }
}
