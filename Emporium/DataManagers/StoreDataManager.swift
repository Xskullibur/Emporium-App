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
     Get stores by merchant Id
     */
    func getStoreByMerchantId(_ merchantId: String, onComplete: @escaping ([GroceryStore]) -> Void, onError: @escaping (String) -> Void) {
        
        storeCollection.whereField("merchant", isEqualTo: merchantId)
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    onError(error.localizedDescription)
                }
                else {
                    
                    guard let documents = querySnapshot?.documents else {
                        onError("Document not found")
                        return
                    }
                    
                    if documents.count > 0 {
                        
                        var storeList: [GroceryStore] = []
                        for document in documents {
                            let data = document.data()
                            let store = GroceryStore(
                                id: document.documentID,
                                name: data["name"] as! String,
                                address: data["address"] as! String,
                                location: data["coordinates"] as! GeoPoint
                            )
                            storeList.append(store)
                        }
                        onComplete(storeList)
                        
                    }
                    else {
                        onComplete([])
                    }
                    
                }
                
                
        }
        
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
    
    func getStore(storeId: String, onComplete: @escaping (GroceryStore) -> Void) {
        
        storeCollection.document(storeId).getDocument { (documentSnapshot, error) in
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
            
            let store = GroceryStore(
                id: storeId,
                name: data["name"] as! String,
                address: data["address"] as! String,
                location: data["coordinates"] as! GeoPoint,
                currentVisitorCount: data["current_visitor_count"] as! Int,
                maxVisitorCapacity: data["max_visitor_capacity"] as! Int
            )
            
            onComplete(store)
            
        }
        
    }
}
