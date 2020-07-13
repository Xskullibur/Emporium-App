//
//  ScanDetail.swift
//  Emporium
//
//  Created by user1 on 11/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class ScanDetail: NSObject {
    var cardNumber: String = ""
    var month: Int = 0
    var year: Int = 0
    var bank: Int = 0
    
    init(number: String, month: Int, year: Int, bank: Int, name: String) {
        self.cardNumber = number
        self.month = month
        self.year = year
        self.bank = bank
    }

}
