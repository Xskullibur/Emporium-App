//
//  RequestedItem.swift
//  Emporium
//
//  Created by Xskullibur on 25/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class RequestedItem {
    
    enum ItemStatus {
        case NotPickedUp
        case PickedUp
        case NotAvailable
    }
    
    var cart: Cart2
    var status: ItemStatus
    
    init(cart _cart: Cart2, itemStatus _status: ItemStatus = .NotPickedUp) {
        cart = _cart
        status = _status
    }
    
    static func getDebug() -> [RequestedItem] {
        
        return [
        
            RequestedItem(
                cart: Cart2(
                    product: Product("P001", "Salt", 9999, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Frice.jpg?alt=media&token=ada819ab-329b-4e5d-80b6-055b4de5a927", "Snack"),
                    quantity: 2
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P002", "Chips", 1.2, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Fpotatochip.jpg?alt=media&token=a88cb80f-9918-4fd1-96e4-7ccb86f8e4f0", "Snack"),
                    quantity: 2
                ),
                itemStatus: .PickedUp
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P003", "Cheese", 9999, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2FSwiss-Cheese.jpg?alt=media&token=5fdf81b7-183f-4d45-b2b9-b78ddf67ad89", "Snack"),
                    quantity: 2
                ),
                itemStatus: .NotAvailable
            ),
        
        ]
        
    }
    
}
