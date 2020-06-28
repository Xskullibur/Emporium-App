//
//  StoreDataManager.swift
//  Emporium
//
//  Created by Xskullibur on 17/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FirebaseFirestore

class StoreDataManager {
    
    static let db = Firestore.firestore()
    static let storeCollection = db
        .collection("emporium")
        .document("globals")
        .collection("grocery_stores")
    
    static func getStores(storeList: [GroceryStore],
                          onComplete: @escaping([[String: Any?]]) -> Void){
        
        storeCollection.whereField(FieldPath.documentID(), in: storeList.map { $0.id })
            .getDocuments { (querySnapshot, error) in
            
                if let error = error {
                    print("Error getting store documents: \(error)")
                }
                else {
                    
                    var storeList: [[String: Any?]] = []
                    
                    for doc in querySnapshot!.documents {
                        
                        let data = doc.data()
                        storeList.append(data)
                        
                    }
                    
                    onComplete(storeList)
                    
                }
                
        }
        
    }
    
    static func updateStores(storeList: [GroceryStore]) {
        let batch = db.batch()
        
        for store in storeList {
            
            let ref = storeCollection.document(store.id)
            
            batch.setData([
                "name": store.name,
                "address": store.address,
                "coordinates": store.location
            ], forDocument: ref)
        }
        
        batch.commit() { error in
            if let error = error {
                print("Error writing batch \(error)")
            }
            else {
                print("Batch write successful")
            }
        }
        
    }
    
}
