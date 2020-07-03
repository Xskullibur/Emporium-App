//
//  PointDataManager.swift
//  Emporium
//
//  Created by Peh Zi Heng on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase

class PointDataManager {
    /**
     Get the current points that the user has
     */
    func getPoints(user: User,  completion: @escaping (Int) -> Void){
        let db = Firestore.firestore()
        
        //Get reference to user
        let userRef = db.collection("users").document(user.uid)
        
        userRef.addSnapshotListener{
            querySnapshot, error in
            
            if let document = querySnapshot, document.exists {
                let points = document.data()?["points"] as? Int ?? 0
                completion(points)
            }else{
                completion(0)
            }
            
        }
        
        
    }
    
}
