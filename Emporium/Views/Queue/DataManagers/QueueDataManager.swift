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

class QueueDataManager {
    
    static let db = Firestore.firestore()
    static let userID = Auth.auth().currentUser!.uid
    static let storeCollection = db
        .collection("emporium")
        .document("globals")
        .collection("grocery_stores")
    
    enum QueueStatus {
        case inStore
        case completed
    }
 
    static func updateQueueStatus(status: QueueStatus, queueId: String) {
        
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
