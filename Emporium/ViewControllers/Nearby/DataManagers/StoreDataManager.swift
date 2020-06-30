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
    
    static func visitorCountListener(store: GroceryStore, onUpdate: @escaping (Int) -> Void) {
        
        storeCollection.document(store.id)
            .addSnapshotListener { (documentSnapshot, error) in
                
                guard let document = documentSnapshot else {
                    print("Error fetching document. (VisitorCount.Listener): \(error!)")
                    return
                }
                
                guard let data = document.data() else {
                    print("Document data was empty. (VisitorCount.Listener)")
                    return
                }
                
                guard let visitorCount = data["current_visitor_count"] else {
                    print("Field data was empty. (VisitorCount.Listener)")
                    return
                }
                
                if let error = error {
                    print("Error retreiving collection. (VisitorCount.Listener): \(error)")
                    return
                }
                
                onUpdate(visitorCount as! Int)
                
        }
        
    }
    
    static func updateStores(storeList: [GroceryStore]) {
        let batch = db.batch()
        
        for store in storeList {
            
            let ref = storeCollection.document(store.id)
            
            batch.setData([
                "id": store.id,
                "name": store.name,
                "address": store.address,
                "coordinates": store.location,
                "current_visitor_count": store.currentVisitorCount,
                "max_visitor_capacity": store.maxVisitorCapacity
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
