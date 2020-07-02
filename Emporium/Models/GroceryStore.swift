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
    let location: GeoPoint
    
     var distance: Double?
    
    var currentVisitorCount: Int
    var maxVisitorCapacity: Int
    
    init(
        id _id: String,
        name _name: String,
        address _address: String,
        distance _distance: Double,
        latitude _latitude: Double,
        logitude _longitude: Double,
        
        maxCount _maxCount: Int = 40,
        crowdCount _crowdCount: Int = 0
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
    
    enum CrowdLevel {
        case low
        case medium
        case high
    }
    
    func getCrowdLevel() -> CrowdLevel {
        if currentVisitorCount >= (maxVisitorCapacity / 3 * 2) {
            return .high
        }
        else if currentVisitorCount >= (maxVisitorCapacity / 3) {
            return .medium
        }
        else {
            return .low
        }
    }
    
    func getCrowdLevelColor() -> (UIColor) {
        
        // Custom Marker
        let lowColor = UIColor.systemGreen
        let midColor = UIColor.systemOrange
        let highColor = UIColor.systemRed

        switch getCrowdLevel() {
            case .low:
                return lowColor
            case .medium:
                return midColor
            case .high:
                return highColor
        }
        
    }
    
}
