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
    
    static func loadCategory(selectedCategory: [String], onComplete: (([Product]) -> Void)?)
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
                    if selectedCategory.contains(doc.get("category") as! String) {
                        let productID: String = String(doc.documentID)
                        let name = doc.get("name") as! String
                        let price = doc.get("price") as! Double
                        let category = doc.get("category") as! String
                        let image = doc.get("image") as! String
                        
                        productData.append(Product(productID, name, price, image, category))
                    }
                }
            }
                
            onComplete?(productData)
        }
    }
    
    static func loadSelectedHistory(selected: [String], onComplete: (([History]) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("order").getDocuments()
        {
            (querySnapshot, err) in
            
            var purchaseHistory: [History] = []
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for doc in querySnapshot!.documents
                {
                    if selected.contains(doc.get("received") as! String) {
                        let amount: Int = doc.get("amount") as! Int
                        let date = String(doc.documentID)
                        let receive = doc.get("received") as! String
                        purchaseHistory.append(History(amount: amount, date: date, received: receive))
                    }
                }
            }
            onComplete?(purchaseHistory.reversed())
        }
    }
    
    static func loadHistory(onComplete: (([History]) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("order").getDocuments()
        {
            (querySnapshot, err) in
            
            var purchaseHistory: [History] = []
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for doc in querySnapshot!.documents
                {
                    let amount: Int = doc.get("amount") as! Int
                    let date = String(doc.documentID)
                    let receive = doc.get("received") as! String
                    purchaseHistory.append(History(amount: amount, date: date, received: receive))
                }
            }
            onComplete?(purchaseHistory.reversed())
        }
    }
    
    static func loadHistoryDetail(docID: String, onComplete: (([HistoryItem]) -> Void)?) {
        
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("order").document(docID).getDocument
        {
            (document, err) in
            
            var cartDetailItems: [[String: Any]] = []
            var histories: [HistoryItem] = []

            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                cartDetailItems = document?.get("cartDetailItems") as! [[String: Any]]
                
                for cartDetailItem in cartDetailItems {
                    let productID = ((cartDetailItem["cartItem"] as! [String:Any])["array"] as! [Any])[0] as! String
                    let quantity = ((cartDetailItem["cartItem"] as! [String:Any])["array"] as! [Any])[1] as! Int
                    let name = cartDetailItem["name"] as! String
                    let price = cartDetailItem["price"] as! Double
                    let image = cartDetailItem["image"] as! String
                    histories.append(HistoryItem(productID, quantity, name, price, image))
                }
                
            }
            onComplete?(histories)
        }
    }
    
    static func loadHistoryPaymentDetail(docID: String, onComplete: ((HistoryPaymentDetail) -> Void)?) {
        
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("order").document(docID).getDocument
        {
            (document, err) in
            
            var details: HistoryPaymentDetail = HistoryPaymentDetail(amount: 0, type: "", last4: "", brand: "", receipt: "")
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                details.amount = document?.get("amount") as! Int
                details.type = document?.get("cardType") as! String
                details.brand = document?.get("cardBrand") as! String
                details.last4 = document?.get("last4") as! String
                details.receipt = document?.get("receipt") as! String
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
                    let nickname = doc.get("nickname") as! String
                    let bank = doc.get("bank") as! String
                    
                    cardList.append(Card(fp: fp, brand: brand, cardType: cardType, last4: last4, expMonth: expMonth, expYear: expYear, nick: nickname, bank: bank))
                }
                 onComplete?(cardList)
            }
        }
    }
    
    static func addShoppingList(list: [Any], name: String) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("shopping_list").document(name).setData([
            "list": list
        ])
    }
     
}
