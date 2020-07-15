//
//  HistoryPaymentDetail.swift
//  Emporium
//
//  Created by user1 on 15/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class HistoryPaymentDetail: NSObject {
    var amount: String = ""
    var brand: String = ""
    var type: String = ""
    var last4: String = ""
    var receipt: String = ""
    
    init(amount: String, type: String, last4: String, brand: String, receipt: String) {
        self.amount = amount
        self.type = type
        self.last4 = last4
        self.brand = brand
        self.receipt = receipt
    }
}
