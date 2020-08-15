//
//  DeliveryDataManager.swift
//  Emporium
//
//  Created by Xskullibur on 16/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase

class DeliveryDataManager {
    
    func verifyAndCompleteDelivery(deliveryId: String, onComplete: @escaping (Bool) -> Void, onError: @escaping (String) -> Void) {
        
        let errorMsg = "Invalid Delivery Number, please try again."
        onComplete(true)
    
    }
    
    /**
     Check for orders
     */
    static func checkVolunteerRequest(storeId: String, receiveOrder: @escaping (Order?) -> Void){
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in
               let session  = URLSession.shared
               let url = URL(string: Global.BACKEND_SERVER_HOST + "/requestOrder")
               var request = URLRequest(url: url!)
               request.httpBody = "storeId=\(storeId)".data(using: .utf8)
                
               request.httpMethod = "POST"
               request.setValue("Bearer \(token!)", forHTTPHeaderField:"Authorization")
               
               session.dataTask(with: request) {
                   data, response, error in
                   if let httpResponse = response as? HTTPURLResponse {
                       if httpResponse.statusCode == 200 {
                        print("Requested for order")
                        
                        let dataStr = String(decoding: data!, as: UTF8.self)
                        let orderData = Data(base64Encoded: dataStr, options: .ignoreUnknownCharacters)
                        let order = try? Order(serializedData: orderData!)
                        
                        receiveOrder(order)
                        
                        
                       }else{
                        receiveOrder(nil)
                    }
                   }
               }.resume()
        })
        
    }
    
    
}
