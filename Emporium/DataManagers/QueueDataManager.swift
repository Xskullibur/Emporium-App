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
 
    func updateQueueStatus(status: QueueStatus, queueId: String) {
        
        let queueDocumment = db.document("users/\(userID)/queue/\(queueId)")
        
        switch status {
                        
            case .inStore:
                queueDocumment.updateData([
                    "status": "InStore"
                ]) { (error) in
                    if let error = error {
                        print("Error updating document (UpdateQueue.\(queueId).InStore): \(error)")
                    } else {
                        print("Document successfully updated")
                    }
                }

            case .completed:
                queueDocumment.updateData([
                    "status": "Completed"
                ]) { (error) in
                    if let error = error {
                        print("Error updating document (UpdateQueue.\(queueId).Completed): \(error)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            
        }
        
    }
    
}
