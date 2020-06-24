//
//  Cart2.swift
//  Emporium
//
//  Created by Xskullibur on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class Cart2: NSObject {
    
    var product: Product
    var quantity: Int
    
    init(product _product: Product, quantity _quantity: Int) {
        product = _product
        quantity = _quantity
    }
    
}
