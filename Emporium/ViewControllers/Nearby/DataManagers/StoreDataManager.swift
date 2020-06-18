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
    static let globalDocument = db.collection("emporium").document("globals")
    
    static func updateStores(storeList: [GroceryStore]) {
        let storeCollection = globalDocument.collection("grocery_stores")
        let batch = db.batch()
        
        for store in storeList {
            
            let ref = storeCollection.document(store.id)
            
            batch.setData([
                "name": store.name,
                "address": store.address,
                "coordinates": GeoPoint(latitude: store.latitude, longitude: store.longitude)
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
