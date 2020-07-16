//
//  History.swift
//  Emporium
//
//  Created by history on 14/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class History: Codable {
    var amount: String = ""
    var date: String = ""
    var received: String = ""
    
    init(amount: String, date: String, received: String) {
        self.amount = amount
        self.date = date
        self.received = received
    }
}
