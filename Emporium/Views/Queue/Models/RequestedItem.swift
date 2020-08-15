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
    
    static func getItems(carts: [Cart2]) -> [RequestedItem] {
        
        var requestedItems: [RequestedItem] = []
        for cart in carts {
            requestedItems.append(RequestedItem(cart: cart))
        }
        return requestedItems
        
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
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P003", "Cheese", 9999, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2FSwiss-Cheese.jpg?alt=media&token=5fdf81b7-183f-4d45-b2b9-b78ddf67ad89", "Snack"),
                    quantity: 2
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P004", "Rice", 3.1, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Frice.jpg?alt=media&token=ada819ab-329b-4e5d-80b6-055b4de5a927", "Snack"),
                    quantity: 1
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P005", "Coke", 0.5, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Fcoca-cola.png?alt=media&token=47bb20cb-d62d-44ae-a59a-e652bcaa24af", "Beverage"),
                    quantity: 5
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P006", "Ice Cream", 1.2, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Ficecream.jpg?alt=media&token=551d1b9f-404c-42c3-931c-3e97b0c8be94", "Chilled"),
                    quantity: 4
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P007", "Milk", 1, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Fmilk.jpg?alt=media&token=736daf8c-0168-4ff7-b115-8353d0443043", "Dairy"),
                    quantity: 2
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P008", "Steak", 10.9, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Fsteak.jpg?alt=media&token=9a50bc70-1238-48c8-9d9c-ac505cb76856", "Meat"),
                    quantity: 4
                )
            ),
            RequestedItem(
                cart: Cart2(
                    product: Product("P009", "Butter", 3.6, "https://firebasestorage.googleapis.com/v0/b/emporium-e8b60.appspot.com/o/productImage%2Fbutter.jpg?alt=media&token=3bdb95dd-1f80-450c-81c1-11b294e391eb", "Dairy"),
                    quantity: 1
                )
            ),
        
        ]
        
    }
    
}
