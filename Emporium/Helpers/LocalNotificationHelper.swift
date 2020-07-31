//
//  LocalNotificationHelper.swift
//  Emporium
//
//  Created by ITP312Grp1 on 27/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationHelper {
    
    init() {
        
    }
    
    static func createNotificationContent(
        title _title: String,
        body _body: String,
        subtitle _subtitle: String?,
        others _others: [AnyHashable: Any]?
    ) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = _title
        content.body = _body
        
        if let subtitle = _subtitle {
            content.subtitle = subtitle
        }
        if let others = _others {
            content.userInfo = others
        }
        
        return content
        
    }
    
    static func addNotification(
        identifier _identifier: String,
        content _content: UNNotificationContent,
        trigger _trigger: UNNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    ) {
        
        let request = UNNotificationRequest(identifier: _identifier, content: _content, trigger: _trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            
            if let error = error {
                print("Error Adding Notification (\(_identifier)): \(error.localizedDescription)")
            }
            
        }
        
    }
    
}
