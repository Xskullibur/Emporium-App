//
//  Card.swift
//  Emporium
//
//  Created by user1 on 2/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class Card: Codable {

    var fingerPrint: String = ""
    var brand: String = ""
    var cardType: String = ""
    var last4: String = ""
    var expMonth: String = ""
    var expYear: String = ""
    
    init(fp: String, brand: String, cardType: String, last4: String, expMonth: String, expYear: String) {
        self.fingerPrint = fp
        self.brand = brand
        self.cardType = cardType
        self.last4 = last4
        self.expMonth = expMonth
        self.expYear = expYear
    }
}
