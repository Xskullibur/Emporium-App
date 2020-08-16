//
//  CrowdTrackingDataManager.swift
//  Emporium
//
//  Created by Peh Zi Heng on 25/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FirebaseFunctions
import Firebase

class CrowdTrackingDataManager {
    
    lazy var functions = Functions.functions()
    
    
    init (){
        functions.useFunctionsEmulator(origin: Global.FIREBASE_HOST)

    }
    /**
     Change the visitor count of a grocery store inside Firebase
     */
    func addVisitorCount(groceryStoreId: String, value: Int, completion: ((ChangeVisitorCountStatus?) -> Void)?){
        functions.httpsCallable("visitorIncreaseOrDecrease").call(["grocery_storeId": groceryStoreId, "value": value]){
            result, error in
            
            if let error = error as NSError? {
                completion?(.error(error))
            }
            
            if let status = (result?.data as? [String: Any])?["status"] as? String {
                if status == "Success"{
                    completion?(.success)
                }
                else{
                    completion?(.error(StringError.stringError(status)))
                }
            }
            
            
        }
    }
    
    /**
    Get the list of Grocery Stores in Firebase
     */
    func getGroceryStores(completion: @escaping([GroceryStore], EmporiumError?) -> Void){
        let database = Firestore.firestore()
        
        let groceryStores = database.collection("emporium/globals/grocery_stores/")
        
        groceryStores.addSnapshotListener{
            (querySnapshot, error) in
            if let error = error {
                completion([], .firebaseError(error))
            }
            
             var datas: [GroceryStore] = []
             
             if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    var data = document.data()
                    data["id"] = document.documentID
                    datas.append(self.toGroceryStore(data: data))
                }
            }
            
             completion(datas, nil)
        }
        
        
    }
    
    /**
     Get GroceryStore from Firebase
     */
    func getGroceryStore(groceryStoreId: String, completion: @escaping (GroceryStore?, EmporiumError?) -> Void){
        let database = Firestore.firestore()
        
        //Get grocery store reference
        let groceryStoreRef = database.document("emporium/globals/grocery_stores/\(groceryStoreId)")
        
        groceryStoreRef.addSnapshotListener{
            (querySnapshot, error) in
            if let error = error {
                completion(nil, .firebaseError(error))
            }
            
            let data = querySnapshot?.data()
            
            completion(self.toGroceryStore(data: data!), nil)
            
        }
    }
    
    private func toGroceryStore(data: [String: Any]) -> GroceryStore{
        let id = data["id"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let address = data["address"] as? String ?? ""
        let location = data["coordinates"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        let currentVisitorCount = data["current_visitor_count"] as? Int ?? 0
        let maxVisitorCapacity = data["max_visitor_capacity"] as? Int ?? 0
        return GroceryStore(id: id, name: name, address: address, location: location, currentVisitorCount: currentVisitorCount,
                            maxVisitorCapacity: maxVisitorCapacity)
    }
    
}
