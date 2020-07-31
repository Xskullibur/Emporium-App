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
            if let error = error as NSError?{
                switch StorageErrorCode(rawValue: error.code) {
                case .objectNotFound:
                    //Check if error is not found -> User has not set a profile image
                    completion?(nil, nil)
                default:
                    //Error
                    completion?(nil, error)
                }
                return
            }
            
            let image = UIImage(data: data!)
            completion?(image, nil)
            
        }
        
        
    }
    
    /**
     Get the user delivery addresses
     */
    static func getUserAddresses(_ user: User, completion: @escaping ([Address]?, EmporiumError?) -> Void){
        let database = Firestore.firestore()
        
        let addressesRef = database.collection("users/\(user.uid)/delivery_addresses")
        
        addressesRef.addSnapshotListener{
            (querySnapshot, error) in
            if let error = error {
                completion([], .firebaseError(error))
            }
            
             var datas: [Address] = []
             
             if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    let data = document.data()
                    
                    let location = data["location"] as! GeoPoint
                    let address = data["address"] as! String
                    let postal = data["postal"] as! String
                    let name = data["name"] as! String
                    
                    datas.append(Address(id: document.documentID, location: location, postal: postal, address: address, name: name))
                }
            }
            completion(datas, nil)
        }
    }
    
    /**
     Get the user delivery addresses
     */
    static func addUserAddresses(user: User, address: Address){
        let database = Firestore.firestore()
        
        let addressesRef = database.collection("users/\(user.uid)/delivery_addresses")
        
        addressesRef.addDocument(data: [
            "name":address.name,
            "location":address.location,
            "postal": address.postal,
            "address": address.address])
    }
    
    /**
     Get the user delivery addresses
     */
    static func updateUserAddresses(user: User, address_id id: String, address: Address){
        let database = Firestore.firestore()
        
        let addressRef = database.document("users/\(user.uid)/delivery_addresses/\(id)")
        
        addressRef.updateData([
            "name":address.name,
            "location":address.location,
            "postal": address.postal,
            "address": address.address], completion: nil)
    }
    
    /**
     Get the user delivery addresses
     */
    static func deleteUserAddresses(user: User, address: Address){
        let database = Firestore.firestore()
        
        let addressRef = database.document("users/\(user.uid)/delivery_addresses/\(address.id!)")
        addressRef.delete()
    }
    
    private static func getUserStorageReference(_ user: User) -> StorageReference {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("users/\(user.uid)")
        return storageRef
    }
    
    
}
