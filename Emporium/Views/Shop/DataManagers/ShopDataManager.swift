//
//  ShopDataManager.swift
//  Emporium
//
//  Created by hsienxiang on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class ShopDataManager
{
    static let db = Firestore.firestore()
    
    static func loadProducts(onComplete: (([Product]) -> Void)?)
    {
        db.collection("emporium").document("globals").collection("products").getDocuments()
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
    
    static func loadHistory(onComplete: (([String]) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("order").getDocuments()
        {
            (querySnapshot, err) in
            
            var purchaseHistory: [String] = []
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for doc in querySnapshot!.documents
                {
                    purchaseHistory.append(doc.documentID)
                }
            }
            onComplete?(purchaseHistory.reversed())
        }
    }
    
    static func loadHistoryDetail(docID: String, onComplete: (([String]) -> Void)?) {
        
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("order").document(docID).getDocument
        {
            (document, err) in
            
            var details: [String] = []
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                details = document?.get("cartDetail") as! [String]
            }
            onComplete?(details)
        }
    }
    
    static func loadCards(onComplete: (([Card]) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("cards").getDocuments()
        {
            (querySnapshot, err) in
            
            var cardList: [Card] = []
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for doc in querySnapshot!.documents
                {
                    let fp = String(doc.documentID)
                    let brand = doc.get("brand") as! String
                    let cardType = doc.get("cardType") as! String
                    let last4 = doc.get("last4") as! String
                    let expMonth = "\(doc.get("expMonth") ?? "0")"
                    let expYear = "\(doc.get("expYear") ?? "0000")"
                    
                    cardList.append(Card(fp: fp, brand: brand, cardType: cardType, last4: last4, expMonth: expMonth, expYear: expYear))
                }
                 onComplete?(cardList)
            }
        }
    }
     
}
