//
//  ShopDataManager.swift
//  Emporium
//
//  Created by user1 on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ShopDataManager
{
    static let db = Firestore.firestore()
    
    static func loadProducts(onComplete: (([Product]) -> Void)?)
    {
        db.collection("products").getDocuments()
            {
            (querySnapshot, err) in
            
            var productData: [Product] = []
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for doc in querySnapshot!.documents
                {
                    let productID: String = String(doc.documentID)
                    let name = doc.get("name") as! String
                    let price = doc.get("price") as! Double
                    let category = doc.get("category") as! String
                    let image = doc.get("image") as! String
                    
                    productData.append(Product(productID, name, price, image, category))
                }
            }
                
            onComplete?(productData)
        }
    }
}
