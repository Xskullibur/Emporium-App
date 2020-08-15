//
//  NotificationHandler.swift
//  Emporium
//
//  Created by Peh Zi Heng on 11/6/20.
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
    
    private var userNotificationPublisher: CurrentValueSubject<[[String: Any]], EmporiumError>?
    private var globalNotificationPublisher: CurrentValueSubject<[[String: Any]], EmporiumError>?
    
    private var notificationRef: CollectionReference?
    private var globalNotificationRef: CollectionReference?
    
    // Array for listeners
    var globalListener: ListenerRegistration? = nil
    var userListener: ListenerRegistration? = nil
    
    //Create a global reference
    public static let shared = NotificationHandler()
    
    func reset(){
        //Send empty objects to reset the subscribers
        self.userNotificationPublisher?.send([])
        self.globalNotificationPublisher?.send([])
        
        self.userNotificationPublisher = nil
        self.globalNotificationPublisher = nil
        
        self.notificationRef = nil
        self.globalNotificationRef = nil
    }
    
    func create(){
        let db = Firestore.firestore()
        
        //Create notification reference
        self.globalNotificationRef = db.collection("emporium/globals/notifications")
        //Create a user notification reference if the user is login
        if let userId = Auth.auth().currentUser?.uid{
            self.notificationRef = db.collection("users/\(userId)/notifications")
        }
        
        //Publishers for sending notifications
        self.userNotificationPublisher = CurrentValueSubject<[[String: Any]], EmporiumError>([])
        self.globalNotificationPublisher = CurrentValueSubject<[[String: Any]], EmporiumError>([])
        
        //Merge the user and global notifications publisher as one single publisher
        self.notificationPublisher = Publishers.CombineLatest(self.userNotificationPublisher!, self.globalNotificationPublisher!)
            .tryMap{
            (userDatas, globalDatas) -> [EmporiumNotification] in
                return userDatas.map(self.toEmporiumNotification(data:)) +
                    globalDatas.map(self.toEmporiumNotification(data:))
        }.mapError{
            error -> EmporiumError in
            return error as! EmporiumError
        }.eraseToAnyPublisher()
        
        //This is to make sure global notification get receive
        self.userNotificationPublisher?.send([])
        self.globalNotificationPublisher?.send([])
        
    }
    
    /*
     Start listening for current and new notifications
     */
    func start(){
        // MARK: - User Notifications
        if let userListener = userListener {
            userListener.remove()
        }
        userListener = self.notificationRef?.addSnapshotListener{
            (querySnapshot, error) in
            
            if let error = error {
                self.userNotificationPublisher?.send(completion: .failure(.firebaseError(error)))
            }
            
            var datas: [[String: Any]] = []
            
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    let data = document.data()
                    datas.append(data)
                    
                    if let read = data["read"] {
                        if !(read as! Bool) {
                            self.notificationRef?.document(document.documentID).updateData(["read": true], completion: { (error) in
                                
                                if let error = error {
                                    print("Error updating notification (Read.User): \(error.localizedDescription)")
                                }
                                
                            })
                        }
                    }
                    else {
                        self.notificationRef?.document(document.documentID).updateData(["read": true], completion: { (error) in
                            
                            if let error = error {
                                print("Error updating notification (Read.User): \(error.localizedDescription)")
                            }
                            
                        })
                    }
                    
                }
            }
            
            self.userNotificationPublisher?.send(datas)
            
        }
        // MARK: - Global Notifications
        if let globalListener = globalListener {
            globalListener.remove()
        }
        
        globalListener = self.globalNotificationRef?.addSnapshotListener{
            (querySnapshot, error) in

            if let error = error {
                self.globalNotificationPublisher?.send(completion: .failure(.firebaseError(error)))
            }
            
            var datas: [[String: Any]] = []
            
            if let querySnapshot = querySnapshot {
                
                for document in querySnapshot.documents {
                    let data = document.data()
                    datas.append(data)
                }
            }
            
            //This is to make sure global notification get receive
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
        let read = data["read"] as? Bool ?? false
        
        // Local Notification
        let content = LocalNotificationHelper.createNotificationContent(title: title, body: message, subtitle: sender, others: nil)
        LocalNotificationHelper.addNotification(identifier: "\(sender).notification", content: content)
        
        return EmporiumNotification(sender: sender, title: title, message: message, date: date, priority: 1, read: read)
    }
    
}
