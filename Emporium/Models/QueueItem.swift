//
//  QueueItem.swift
//  Emporium
//
//  Created by Xskullibur on 9/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class QueueItem: NSObject {
    
    let id: String
    let userId: String
    let date: Date
    let status: String
    
    init(id _id: String, userId _userId: String, date _date: Date, status _status: String) {
        id = _id
        userId = _userId
        date = _date
        status = _status
    }
    
}
