//
//  GroceryStore.swift
//  Emporium
//
//  Created by Xskullibur on 8/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase
import UIKit.UIColor

class GroceryStore: NSObject {
    let id: String
    let name: String
    let address: String
    var distance: Double?
    let location: GeoPoint
    
    
    var currentVisitorCount: Int
    let maxVisitorCapacity: Int
    
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
        location = GeoPoint(latitude: _latitude, longitude: _longitude)
        
        currentVisitorCount = _crowdCount
        maxVisitorCapacity = _maxCount
        
    }
    
    init(
        id _id: String,
        name _name: String,
        address _address: String,
        location _location: GeoPoint,
        currentVisitorCount _currentVisitorCount: Int,
        maxVisitorCapacity _maxVisitorCapacity: Int
    ) {
        
        id = _id
        name = _name
        address = _address
        distance = nil
        location = _location
        
        currentVisitorCount = _currentVisitorCount
        maxVisitorCapacity = _maxVisitorCapacity
        
    }
    
    func getCrowdLevelColor() -> (UIColor) {
        
        // Custom Marker
        let lowColor = UIColor.systemGreen
        let midColor = UIColor.systemOrange
        let highColor = UIColor.systemRed
        
        if currentVisitorCount >= (maxVisitorCapacity / 3 * 2) {
            return highColor
        }
        else if currentVisitorCount >= (maxVisitorCapacity / 3) {
            return midColor
        }
        else {
            return lowColor
        }
        
    }
    
}
