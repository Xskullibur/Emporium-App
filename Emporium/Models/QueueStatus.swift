//
//  QueueStatus.swift
//  Emporium
//
//  Created by Xskullibur on 14/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

enum QueueStatus: String {
    case None = ""
    case InQueue = "In Queue"
    case OnTheWay = "On The Way"
    case InStore = "In Store"
    case Delivery = "Delivery"
    case Completed = "Completed"
}
