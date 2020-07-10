//
//  StoreDataManager.swift
//  Emporium
//
//  Created by Xskullibur on 17/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

class StoreDataManager {
    
    let functions = Functions.functions()
    let db = Firestore.firestore()
    let storeCollection: CollectionReference
    
    init() {
        
        storeCollection = db
           .collection("emporium")
           .document("globals")
           .collection("grocery_stores")
        
        #if DEBUG
        let functionsHost = ProcessInfo.processInfo.environment["functions_host"]
        if let functionsHost = functionsHost {
            functions.useFunctionsEmulator(origin: functionsHost)
        }
        #endif
    }
    
    /**
     Firestore **storeId** listener
     
     Returns:
     - data ([String: Any])
     */
    func visitorCountListenerForStore(_ store: GroceryStore, onUpdate: @escaping ([String: Any]) -> Void) -> ListenerRegistration {
        
        return storeCollection.document(store.id)
            .addSnapshotListener { (documentSnapshot, error) in
                
                if let error = error {
                    print("Error retreiving collection. (VisitorCount.Listener): \(error)")
                    return
                }
                
                guard let document = documentSnapshot else {
                    print("Error fetching document. (VisitorCount.Listener): \(error!)")
                    return
                }
                
                guard let data = document.data() else {
                    print("Document data was empty. (VisitorCount.Listener)")
                    return
                }
                
                onUpdate(data)
                
        }
        
    }
    
    /**
     Firestore update store contents
     */
    func updateStore(store: GroceryStore) {
        storeCollection.document(store.id).updateData([
            "id": store.id,
            "name": store.name,
            "address": store.address,
            "coordinates": store.location,
            "current_visitor_count": store.currentVisitorCount,
            "max_visitor_capacity": store.maxVisitorCapacity
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    /**
     Firestore add store
     */
    func addStore(store: GroceryStore) {
        
        storeCollection.document(store.id).setData([
            "id": store.id,
            "name": store.name,
            "address": store.address,
            "coordinates": store.location
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
        
    }    
}
