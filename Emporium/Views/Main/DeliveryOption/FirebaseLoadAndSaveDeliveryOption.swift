//
//  FirebaseSaveDeliveryOptionOnDone.swift
//  Emporium
//
//  Created by Peh Zi Heng on 14/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase

class FirebaseLoadAndSaveDeliveryOption : LoadAndSaveDeliveryOption{
    
    func load(onComplete: @escaping (DeliveryOption) -> Void){
        guard let user = Auth.auth().currentUser else {
            return
        }
        AccountDataManager.getDeliveryOption(user: user){
            (deliveryOption, error) in
            if let deliveryOption = deliveryOption {
                onComplete(deliveryOption)
            }
        }
    }
    
    //Save delivery option into firebase
    func save(_ deliveryOption: DeliveryOption){
        guard let user = Auth.auth().currentUser else {
            return
        }
        AccountDataManager.setDeliveryOption(user: user, option: deliveryOption)
    }
}
