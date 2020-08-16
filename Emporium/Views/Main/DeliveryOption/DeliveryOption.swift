//
//  DeliveryOption.swift
//  Emporium
//
//  Created by Peh Zi Heng on 14/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class DeliveryOption: ObservableObject {
    @Published var distanceInKm = "2"
    
    init(_ data: [String: Any]){
        self.distanceInKm = String(((data["distanceInKm"] as? Double) ?? 2))
    }
    
    init(){}
    
    /**
     Convert this class into a Dictionary that can be saved into Firebase
     */
    func toData() -> [String: Any] {
        return [
            "distanceInKm": Double(self.distanceInKm)
        ]
    }
    
}
