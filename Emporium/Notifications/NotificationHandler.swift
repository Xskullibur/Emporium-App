//
//  NotificationHandler.swift
//  Emporium
//
//  Created by Riyfhx on 11/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Combine
import Firebase
import Foundation

class NotificationHandler {
    
    //Create a publisher for sending/emitting notifications
    private var notificationPublisher: PassthroughSubject<[[String: Any]], EmporiumError>?
    
    private var notificationRef: CollectionReference?
    
    //Create a global reference
    public static let shared = NotificationHandler()
    
    func create(){
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        
        //Create notification reference
        self.notificationRef = db.collection("users/\(userId)/notifications")
        
        self.notificationPublisher = PassthroughSubject<[[String: Any]], EmporiumError>()


    }
    
    func start(){
        self.notificationRef?.addSnapshotListener{
            (querySnapshot, error) in

            if let error = error {
                self.notificationPublisher?.send(completion: .failure(.firebaseError(error)))
            }
            
            var datas: [[String: Any]] = []
            
            for document in querySnapshot!.documents {
                datas.append(document.data())
            }

            self.notificationPublisher?.send(datas)
        }
    }
    
    func getNotifications() -> AnyPublisher<[EmporiumNotification], EmporiumError>? {
        return self.notificationPublisher?.tryMap{
            datas -> [EmporiumNotification] in
            return datas.map{
                data in
                let sender = data["sender"] as? String ?? ""
                let title = data["title"] as? String ?? ""
                let message = data["message"] as? String ?? ""
                let date = (data["date"] as? String)?.isoToDate() ?? Date()
                return EmporiumNotification(sender: sender, title: title, message: message, date: date, priority: 1)
            }
        }.mapError{
            error -> EmporiumError in
            return error as! EmporiumError
        }.eraseToAnyPublisher()
    }
    
}

extension String {
    func isoToDate() -> Date?{
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self)
    }
}
