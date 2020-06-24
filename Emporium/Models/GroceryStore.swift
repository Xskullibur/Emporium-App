//
//  GroceryStore.swift
//  Emporium
//
//  Created by Xskullibur on 8/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import UIKit.UIColor

class GroceryStore: NSObject {
    let id: String
    let name: String
    let address: String
    let distance: Double
    let latitude: Double
    let longitude: Double
    
    let crowdCount: Int
    let maxCount: Int
    
    init(
        id _id: String,
        name _name: String,
        address _address: String,
        distance _distance: Double,
        latitude _latitude: Double,
        logitude _longitude: Double,
        
        maxCount _maxCount: Int = 40,
        crowdCount _crowdCount: Int = Int.random(in: 0...40)
    ) {
        
        id = _id
        name = _name
        address = _address
        distance = _distance
        latitude = _latitude
        longitude = _longitude
        
        crowdCount = _crowdCount
        maxCount = _maxCount
        
    }
    
    func getCrowdLevelColor() -> (UIColor) {
        
        // Custom Marker
        let lowColor = UIColor.systemGreen
        let midColor = UIColor.systemOrange
        let highColor = UIColor.systemRed
        
        if crowdCount >= (maxCount / 3 * 2) {
            return highColor
        }
        else if crowdCount >= (maxCount / 3) {
            return midColor
        }
        else {
            return lowColor
        }
        
    }
    
}
