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

/*
 Handles all notifications collections from Firestore
 
 - Firestore Paths
 'users/\(userId)/notifications' - User specific notifications
 'emporium/globals/notifications' - Broadcast notifications
 
 */
class NotificationHandler {
    
    //Create a publisher for sending/emitting notifications
    private var notificationPublisher: AnyPublisher<[EmporiumNotification], EmporiumError>?
    
    private var userNotificationPublisher: PassthroughSubject<[[String: Any]], EmporiumError>?
    private var globalNotificationPublisher: PassthroughSubject<[[String: Any]], EmporiumError>?
    
    private var notificationRef: CollectionReference?
    private var globalNotificationRef: CollectionReference?
    
    //Create a global reference
    public static let shared = NotificationHandler()
    
    func create(){
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        
        //Create notification reference
        self.notificationRef = db.collection("users/\(userId)/notifications")
        self.globalNotificationRef = db.collection("emporium/globals/notifications")
        
        self.userNotificationPublisher = PassthroughSubject<[[String: Any]], EmporiumError>()
        self.globalNotificationPublisher = PassthroughSubject<[[String: Any]], EmporiumError>()
        
        self.notificationPublisher = Publishers.CombineLatest(self.userNotificationPublisher!, self.globalNotificationPublisher!)
            .tryMap{
            (userDatas, globalDatas) -> [EmporiumNotification] in
                return userDatas.map(self.toEmporiumNotification(data:)) +
                    globalDatas.map(self.toEmporiumNotification(data:))
        }.mapError{
            error -> EmporiumError in
            return error as! EmporiumError
        }.eraseToAnyPublisher()
        
    }
    
    /*
     Start listening for current and new notifications
     */
    func start(){
        //user notifications
        self.notificationRef?.addSnapshotListener{
            (querySnapshot, error) in

            if let error = error {
                self.userNotificationPublisher?.send(completion: .failure(.firebaseError(error)))
            }
            
            var datas: [[String: Any]] = []
            
            for document in querySnapshot!.documents {
                let data = document.data()
                datas.append(data)
            }

            self.userNotificationPublisher?.send(datas)
        }
        //global notifications
        self.globalNotificationRef?.addSnapshotListener{
            (querySnapshot, error) in

            if let error = error {
                self.globalNotificationPublisher?.send(completion: .failure(.firebaseError(error)))
            }
            
            var datas: [[String: Any]] = []
            
            for document in querySnapshot!.documents {
                let data = document.data()
                datas.append(data)
            }

            self.globalNotificationPublisher?.send(datas)
        }
    }
    
    func getNotifications() -> AnyPublisher<[EmporiumNotification], EmporiumError>? {
        return self.notificationPublisher
    }
    
    private func toEmporiumNotification(data: [String: Any]) -> EmporiumNotification {
        let sender = data["sender"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let message = data["message"] as? String ?? ""
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        return EmporiumNotification(sender: sender, title: title, message: message, date: date, priority: 1)
    }
    
}
