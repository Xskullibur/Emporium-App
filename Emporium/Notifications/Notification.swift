//
//  Notification.swift
//  Emporium
//
//  Created by Peh Zi Heng on 11/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

struct EmporiumNotification {
    let sender: String
    let title: String
    let message: String
    let date: Date
    let priority: Int
    
    let read: Bool
}
