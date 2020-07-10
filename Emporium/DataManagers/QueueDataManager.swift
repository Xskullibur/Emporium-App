//
//  QueueDataManager.swift
//  Emporium
//
//  Created by Xskullibur on 2/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

class QueueDataManager {
    
    let functions = Functions.functions()
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    let storeCollection: CollectionReference
    
    enum QueueStatus {
        case inStore
        case completed
    }
    
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
     Call Firebase Function **queueInfo**
     
     Returns:
     - currentlyServing (String)
     - queueLength (String)
     */
    func getQueueInfo(storeId: String, onComplete: @escaping (String, String) -> Void) {
        
        functions.httpsCallable("queueInfo").call(["storeId": storeId]) { (result, error) in
         
            #warning("TODO: Handle Errors")
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain{
                    let code = FunctionsErrorCode(rawValue: error.code)?.rawValue
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey].debugDescription
                    
                    print("Error joining queue: Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                }
                print(error.localizedDescription)
            }
            
            if let data = (result?.data as? [String: Any]) {
                let queueLength = data["queueLength"] as? String
                let currentlyServing = data["currentlyServing"] as? String
                
                onComplete(currentlyServing!, queueLength!)
            }
            
        }

    }
    
    /**
     Call Firebase Function **joinQueue**
     
     Returns:
     - data ([String : Any])
     */
    func joinQueue(storeId: String, onComplete: @escaping ([String: Any]) -> Void, onError: @escaping (String) -> Void) {
        functions.httpsCallable("joinQueue").call(["storeId": storeId]) { (result, error) in
         
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain{
                    let code = FunctionsErrorCode(rawValue: error.code)?.rawValue
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey].debugDescription
                    
                    print("Error joining queue: Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                }
                print(error.localizedDescription)
                onError(error.localizedDescription)
            }
            
            if let data = (result?.data as? [String: Any]) {
                onComplete(data)
            }
            
        }
    }
    
    /**
     Call Firebase Function **popQueue**
     
     Returns:
     - data ([String: Any])
     */
    func popQueue(storeId: String, queueId: String, onComplete: @escaping ([String: Any]) -> Void, onError: @escaping (String) -> Void) {
        
        self.functions.httpsCallable("popQueue").call(["queueId": queueId, "storeId": storeId]) { (result, error) in
            
            // Error
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain{
                    let code = FunctionsErrorCode(rawValue: error.code)?.rawValue
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey].debugDescription
                    
                    print("Error joining queue: Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                }
                print(error.localizedDescription)
                onError(error.localizedDescription)
            }
            
            // Data
            if let data = (result?.data as? [String: Any]) {
                onComplete(data)
            }
            
        }
        
    }
}
