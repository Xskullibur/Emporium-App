//
//  StoreDataManager.swift
//  Emporium
//
//  Created by Xskullibur on 17/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MapKit

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
    
    static func getStores(storeList: [GroceryStore], onComplete: @escaping ([GroceryStore]) -> Void) {
        
        var tempList: [GroceryStore] = []
        let idList = storeList.map{ $0.id }
        
        storeCollection.whereField("id", arrayContains: idList)
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    print("Error getting documents: \(error)")
                }
                else {
                    
                    // Add DB data into tempList
                    for document in querySnapshot!.documents {
                        
                        let data = document.data()
                        let store = GroceryStore(
                            id: data["id"] as! String,
                            name: data["name"] as! String,
                            address: data["address"] as! String,
                            location: data["coordinates"] as! GeoPoint,
                            currentVisitorCount: data["current_visitor_count"] as! Int,
                            maxVisitorCapacity: data["max_visitor_capacity"] as! Int
                        )
                        tempList.append(store)
                        
                    }
                    
                    // Update distance and add stores not in DB
                    var missingList: [GroceryStore] = []
                    for store in storeList {
                        
                        let temp = tempList.first { (temp) -> Bool in
                            temp.id == store.id
                        }

                        if temp != nil {
                            temp?.distance = store.distance
                        }
                        else {
                            tempList.append(store)
                            missingList.append(store)
                        }
                        
                    }
                    
                    if missingList.count > 0 {
                        updateStores(storeList: missingList)
                    }
                    
                    onComplete(tempList)
                    
                }
                
        }
        
    }
    
    static func addStore(store: GroceryStore) {
        
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
            ], forDocument: ref, merge: true)
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
