//
//  Product.swift
//  Emporium
//
//  Created by user1 on 13/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class Product: NSObject {

    var id = 0
    var productName = ""
    var price = 0.0
    var image = ""
    
    init(_ id: Int, _ name: String, _ price: Double, _ image: String) {
        self.id = id
        self.productName = name
        self.price = price
        if(image != ""){
            self.image = image
        }
    }

}
