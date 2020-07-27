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
    
    func checkExistingQueue(userId: String, onComplete: @escaping (QueueItem?) -> Void, onError: @escaping (String) -> Void){
        
        // Get User's Queue Ref
        let userRef = db.document("users/\(userId)")
        userRef.getDocument { (userDocumentSnapshot, userError) in
            if let error = userError {
                print("Error retreiving collection. (checkExistingQueue.userRef): \(error)")
                onError(error.localizedDescription)
                return
            }
            
            guard let userDocument = userDocumentSnapshot else {
                print("Error fetching document. (checkExistingQueue.userRef): \(userError!)")
                onComplete(nil)
                return
            }
            
            guard let userData = userDocument.data() else {
                print("Document data was empty. (checkExistingQueue.userRef)")
                onComplete(nil)
                return
            }
            
            // Return Nil if no Ref found
            guard let queue = userData["queue"] else {
                onComplete(nil)
                return
            }
            
            // Get Queue from QueueRef
            let queueRef = queue as! DocumentReference
            queueRef.getDocument { (queueDocumentSnapshot, queueError) in
                if let queueError = queueError {
                    print("Error retreiving collection. (checkExistingQueue.queueRef): \(queueError)")
                    return
                }
                
                guard let queueDocument = queueDocumentSnapshot else {
                    print("Error fetching document. (checkExistingQueue.queueRef): \(queueError!)")
                    return
                }
                
                guard let data = queueDocument.data() else {
                    print("Document data was empty. (checkExistingQueue.queueRef)")
                    return
                }
                
                let storeId = queueDocument.reference.parent.parent!.documentID
                
                let queueItem = QueueItem(
                    id: queueDocument.documentID,
                    storeId: storeId,
                    userId: userId,
                    date: (data["date"] as! Timestamp).dateValue(),
                    status: QueueStatus(rawValue: data["status"] as! String)!
                )
                
                onComplete(queueItem)
                
            }
            
        }
        
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
            else {
                // Check Data
                if let data = (result?.data as? [String: Any]) {
                    let queueLength = data["queueLength"] as? String
                    let currentlyServing = data["currentlyServing"] as? String
                    
                    onComplete(currentlyServing!, queueLength!)
                }
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
            else {
                // Check Data
                if let data = (result?.data as? [String: Any]) {
                    onComplete(data)
                }
            }
            
        }
    }
    
    /**
     Call Firebase Function **popQueue**
     
     Returns:
     - data ([String: Any])
     */
    func popQueue(storeId: String, onComplete: @escaping ([String: Any]) -> Void, onError: @escaping (String) -> Void) {
        
        self.functions.httpsCallable("popQueue").call(["storeId": storeId]) { (result, error) in
            
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
            else {
                // Data
                if let data = (result?.data as? [String: Any]) {
                    onComplete(data)
                }
            }
            
        }
        
    }
    
    func updateQueue(_ queueId: String, withStatus status: QueueStatus, forStoreId storeId: String, onComplete: @escaping (Bool) -> Void) {
        
        let queueDocument = storeCollection.document("\(storeId)/queue/\(queueId)")
        queueDocument.updateData([
            "status": status.rawValue
        ]) { (error) in
            
            if let error = error {
                print("Error updating queue: \(error.localizedDescription)")
                onComplete(false)
            }
            else {
                onComplete(true)
            }
            
        }
        
    }
    
}
