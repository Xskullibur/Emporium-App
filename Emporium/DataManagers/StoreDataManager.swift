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
import FirebaseAuth

class StoreDataManager {
    
    let functions = Functions.functions()
    let db = Firestore.firestore()
    let storeCollection: CollectionReference
    let uid = Auth.auth().currentUser!.uid
    
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
        storeCollection.document(store.id).setData([
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
    
    func storeExist(lat _lat: Double, long _long: Double, onComplete: @escaping (Bool) -> Void, onError: @escaping () -> Void) {
        
        let coordinates = GeoPoint(latitude: _lat, longitude: _long)
        storeCollection.whereField("coordinates", isEqualTo: coordinates).getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error finding store \(error)")
                onError()
            }
            else {
                
                guard let querySnapshot = querySnapshot else {
                    onError()
                    return
                }
                
                if querySnapshot.documents.count > 0 {
                    onComplete(true)
                }
                else {
                    onComplete(false)
                }
                
            }
            
        }
        
    }
    
    /**
     Firestore add store
     */
    func addStore(id _id: String?, name _name: String, address _address: String, lat _lat: Double, long _long: Double, onComplete: @escaping () -> Void, onError: @escaping (String) -> Void) {
        
        // Get Error Msg
        let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
        let data = Plist.readPlist(url!)!
        let errorDescription = data["Error Alert"] as! String
        
        // Check Store Exist
        storeExist(lat: _lat, long: _long, onComplete: { (found) in
            
            if !found {
                // Add Store
                let storeDocument: DocumentReference
                
                // Check for id (Generate if not found)
                if let id = _id {
                    storeDocument = self.storeCollection.document(id)
                }
                else {
                    storeDocument = self.storeCollection.document()
                }
                
                // Commit Update
                storeDocument.setData([
                    "id": storeDocument.documentID,
                    "name": _name,
                    "address": _address,
                    "coordinates": GeoPoint(latitude: _lat, longitude: _long),
                    "current_visitor_count": 0,
                    "max_visitor_capacity": 40,
                    "merchant": self.uid
                ]) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                        onError(errorDescription)
                    } else {
                        print("Document successfully written!")
                        onComplete()
                    }
                }
            }
            else {
                // Return Store Exist
                onError("This Store Already Exist!")
            }
            
        }) {
            // Return Error
            onError(errorDescription)
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
