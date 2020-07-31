//
//  Address.swift
//  Emporium
//
//  Created by Peh Zi Heng on 27/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase

class Address {
    let location: GeoPoint
    let postal: String
    let address: String
    let name: String
    private(set) var id: String? = nil
    
    init(location: GeoPoint, postal: String, address: String, name: String) {
        self.location = location
        self.postal = postal
        self.address = address
        self.name = name
    }
    
    convenience init(id: String, location: GeoPoint, postal: String, address: String, name: String) {
        self.init(location: location, postal: postal, address: address, name: name)
        self.id = id
    }
    
}
