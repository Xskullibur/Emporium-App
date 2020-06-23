//
//  AccountDataManager.swift
//  Emporium
//
//  Created by Riyfhx on 17/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase

class AccountDataManager
{
    /**
     Store profile image into Firebase Storage
     */
    static func setUserProfileImage(user: User, image: UIImage, completion: ((Error?) -> Void)?) {
        
        //Get reference to profile
        let storageRef = self.getUserStorageReference(user)
        let profileImageRef = storageRef.child("\(user.uid).png")
        
        //Get png data
        let data = image.pngData()!
        
        //Upload the png data
        profileImageRef.putData(data, metadata: nil){
            (metadata, error) in
            if let error = error {
                //Error uploading the file
                completion?(error)
                return
            }
            completion?(nil)
        }
        
    }
    
    /**
     Retrieve profile image from Firebase Storage
     */
    static func getUserProfileImage(user: User, completion: ((UIImage?, Error?) -> Void)?){
        
        //Get reference to profile
        let storageRef = self.getUserStorageReference(user)
        let profileImageRef = storageRef.child("\(user.uid).png")
        
        //Allow 5MiB size
        profileImageRef.getData(maxSize: 5*1024*1024){
            data, error in
            if let error = error {
                //Error
                completion?(nil, error)
                return
            }
            
            let image = UIImage(data: data!)
            completion?(image, nil)
            
        }
        
        
    }
    
    private static func getUserStorageReference(_ user: User) -> StorageReference {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("users/\(user.uid)")
        return storageRef
    }
    
    
}
