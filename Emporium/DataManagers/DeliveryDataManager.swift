//
//  DeliveryDataManager.swift
//  Emporium
//
//  Created by Xskullibur on 16/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase
import Combine

enum DeliveryStatus: String
{
    case in_queue = "In Queue"
    case accepted = "Accepted"
    case purchasing = "Purchasing"
    case delivery = "Delivery"
    case completed = "Completed"
}

typealias OrderDeliveryStatus = (status: DeliveryStatus, order: Order, read: Bool)

class DeliveryDataManager {
    
    //Create a global reference
    public static let shared = DeliveryDataManager()
    
    let db = Firestore.firestore()
    
    private var requestedOrdersPublisher: CurrentValueSubject<[[String: Any]], EmporiumError>!
    private var requestedOrdersRef: CollectionReference?
    private var user: User?
    
    init(){
        Auth.auth().addStateDidChangeListener{
           (auth, user) in
           self.user = user
           
           self.reset()
           self.listen()
       }
        self.requestedOrdersPublisher = CurrentValueSubject<[[String: Any]], EmporiumError>([])
        
    }
    
    
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
    
    func listen(){
        guard let user = user else{
            return
        }
        
        let database = Firestore.firestore()
        
        //Get reference to point field
        self.requestedOrdersRef = database.collection("users/\(user.uid)/requested_orders")
        
        self.requestedOrdersRef?.addSnapshotListener{
            (querySnapshot, error) in
            
            if let error = error {
               self.requestedOrdersPublisher?.send(completion: .failure(.firebaseError(error)))
           }
                           
           var datas: [[String: Any]] = []
           
           if let querySnapshot = querySnapshot {
              for document in querySnapshot.documents {
                  var data = document.data()
                  data["id"] = document.documentID
                  datas.append(data)
              }
          }
            
            self.requestedOrdersPublisher.send(datas)
            
        }
    }
    
    func reset(){
        self.requestedOrdersRef = nil
        self.requestedOrdersPublisher?.send([])
    }
    
    
    /**
        Listen for new delivery status
     */
    func getDeliveryStatusUpdate() -> AnyPublisher<[OrderDeliveryStatus], EmporiumError>{
        return self.requestedOrdersPublisher
        .tryMap{
            datas in
            return datas.map(self.toDeliveryStatus(data:))
                .filter{!$0.read}
        }.mapError{
            error in
            return error as! EmporiumError
        }.eraseToAnyPublisher()
    }
    
    
    private func toDeliveryStatus(data: [String: Any]) -> OrderDeliveryStatus{
        let order_data_base64 = data["order_data"] as? String ?? ""
        let orderData = Data(base64Encoded: order_data_base64, options: .ignoreUnknownCharacters)!
        
        let order = try! Order(serializedData: orderData)
    
        let status = DeliveryStatus(rawValue: data["status"] as! String)!
        
        let read = data["read"] as! Bool
        
        let orderDeliveryStatus : OrderDeliveryStatus = (status: status, order: order, read: read)
        return orderDeliveryStatus
    }
    
    func markRequestOrderAsRead(_ orderDeliveryStatus: OrderDeliveryStatus){
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in
               let session  = URLSession.shared
               let url = URL(string: Global.BACKEND_SERVER_HOST + "/markChangesAsRead")
               var request = URLRequest(url: url!)
               request.httpBody = "orderId=\(orderDeliveryStatus.order.orderID)".data(using: .utf8)
                
               request.httpMethod = "POST"
               request.setValue("Bearer \(token!)", forHTTPHeaderField:"Authorization")
               
               session.dataTask(with: request).resume()
        })
    }
    
    func updateDeliveryStatus(status: DeliveryStatus){
        self.user!.getIDToken(completion: {
            token, error in
               let session  = URLSession.shared
               let url = URL(string: Global.BACKEND_SERVER_HOST + "/updateDeliveryStatus")
               var request = URLRequest(url: url!)
            request.httpBody = "status=\(status.rawValue)".data(using: .utf8)
                
               request.httpMethod = "POST"
               request.setValue("Bearer \(token!)", forHTTPHeaderField:"Authorization")
               
               session.dataTask(with: request).resume()
        })
    }
    
    func getDeliveryOrder(onComplete: @escaping (Order?) -> Void){
         self.user!.getIDToken(completion: {
                   token, error in
                      let session  = URLSession.shared
                      let url = URL(string: Global.BACKEND_SERVER_HOST + "/getDeliveryOrder")
                      var request = URLRequest(url: url!)
                       
                      request.httpMethod = "GET"
                      request.setValue("Bearer \(token!)", forHTTPHeaderField:"Authorization")
                      
            session.dataTask(with: request){
                data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                     print("Delivery order")
                     
                     let dataStr = String(decoding: data!, as: UTF8.self)
                     let orderData = Data(base64Encoded: dataStr, options: .ignoreUnknownCharacters)
                     let order = try? Order(serializedData: orderData!)
                     
                     onComplete(order)
                     
                     
                    }else{
                     onComplete(nil)
                 }
                }
            }.resume()
         })
    }
    
    
    
    
}
