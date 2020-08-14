//
//  DeliveryDataManager.swift
//  Emporium
//
//  Created by Xskullibur on 16/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class DeliveryDataManager {
    
    func verifyAndCompleteDelivery(deliveryId: String, onComplete: @escaping (Bool) -> Void, onError: @escaping (String) -> Void) {
        
        let errorMsg = "Invalid Delivery Number, please try again."
        onComplete(true)
    
    }
    
    
    
}
