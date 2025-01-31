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
                        let date = doc.get("time") as! String
                        let receive = doc.get("received") as! String
                        let id = doc.documentID
                        purchaseHistory.append(History(amount: amount, date: date, received: receive, id: id))
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
                    let date = doc.get("time") as! String
                    let receive = doc.get("received") as! String
                    let id = doc.documentID
                    purchaseHistory.append(History(amount: amount, date: date, received: receive, id: id))
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
            
            var details: HistoryPaymentDetail = HistoryPaymentDetail(amount: 0, type: "", last4: "", brand: "", receipt: "", received: "", id: "")
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                if let document = document {
                    details.amount = document.get("amount") as! Int
                    details.type = document.get("cardType") as! String
                    details.brand = document.get("cardBrand") as! String
                    details.last4 = document.get("last4") as! String
                    details.receipt = document.get("receipt") as! String
                    details.received = document.get("received") as! String
                    details.id = document.documentID
                }
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
    
    static func loadShoppingList(onComplete: (([String]) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("shopping_list").getDocuments()
        {
            (querySnapshot, err) in
            
            var namelist: [String] = []
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for doc in querySnapshot!.documents
                {
                    namelist.append(doc.documentID)
                }
                onComplete?(namelist)
            }
        }
    }
    
    static func addShoppingList(list: [Any], name: String) {
        
        let ref = db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("shopping_list").document(name)
        
        ref.getDocument
        {
            (doc, err) in
            
            if let doc = doc
            {
                if doc.exists {
                    Toast.showToast(name + " already exist")
                }else{
                    ref.setData([
                        "list": list
                    ])
                    Toast.showToast("Shopping List Saved!")
                }
            }
        }
    }
    
    static func editShoppingList(list: [Any], name: String) {
        
       let ref = db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("shopping_list").document(name)
        
       ref.setData([
           "list": list
       ])
    }
    
    static func loadShoppingListItems(name: String, onComplete: (([ShoppingList]) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).collection("shopping_list").document(name).getDocument
        {
            (doc, err) in
            
            var itemlist: [ShoppingList] = []
            
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                if let doc = doc {
                    let rawList: [String] = doc.get("list") as! [String]
                    for index in stride(from: 0, to: rawList.count - 1, by: 2) {
                        itemlist.append(ShoppingList(id: rawList[index], quan: Int(rawList[index + 1])!))
                    }
                    onComplete?(itemlist)
                }
            }
        }
    }
    
    static func getOrders(order: Order, onComplete: @escaping ([Cart2]) -> Void) {
        
        var itemList: [Cart2] = []
        db.collection("emporium").document("globals").collection("products").getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error retrieving documents (getProducts): \(error.localizedDescription)")
            }
            else {
                let productIds = order.cartItems.map {$0.productID}
                for document in querySnapshot!.documents {
                    if productIds.contains(document.documentID) {
                        let data = document.data()
                        let product = Product(
                            document.documentID,
                            data["name"] as! String,
                            data["price"] as! Double,
                            data["image"] as! String,
                            data["category"] as! String
                        )
                        let cart = Cart2(
                            product: product,
                            quantity: Int(order.cartItems.first(where: {$0.productID == product.id})!.quantity)
                        )
                        
                        itemList.append(cart)
                    }
                }
                onComplete(itemList)
            }
            
        }
        
    }
    
    static func getCurrentOrder(onComplete: @escaping ([String: Any]) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        db.collection("users/\(uid)/order").whereField("received", isEqualTo: "no").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("\(error)")
            }
            else {
                if let document = querySnapshot?.documents[0] {
                    onComplete(document.data())
                }
            }
            
        }
    }
    
}
