//
//  Product.swift
//  Emporium
//
//  Created by user1 on 13/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class Product: Codable {

    var id = ""
    var productName = ""
    var price = 0.0
    var image = ""
    var category = ""
    
    init(_ id: String, _ name: String, _ price: Double, _ image: String, _ cate: String) {
        self.id = id
        self.productName = name
        self.price = price
        self.category = cate
        if(image != ""){
            self.image = image
        }
    }

}
