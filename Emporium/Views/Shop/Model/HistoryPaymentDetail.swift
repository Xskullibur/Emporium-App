//
//  HistoryPaymentDetail.swift
//  Emporium
//
//  Created by user1 on 15/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class HistoryPaymentDetail: NSObject {
    var amount: Int = 0
    var brand: String = ""
    var type: String = ""
    var last4: String = ""
    var receipt: String = ""
    var received: String = ""
    var id: String = ""
    
    init(amount: Int, type: String, last4: String, brand: String, receipt: String, received: String, id: String) {
        self.amount = amount
        self.type = type
        self.last4 = last4
        self.brand = brand
        self.receipt = receipt
        self.received = received
        self.id = id
    }
}
