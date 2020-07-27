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
    var id: String
    let name: String
    let address: String
    let location: GeoPoint
    
    var distance: Double? = nil
    
    var currentVisitorCount: Int = 40
    var maxVisitorCapacity: Int = Int.random(in: 0...40)
    
    init(
        id _id: String,
        name _name: String,
        address _address: String,
        distance _distance: Double,
        location _location: GeoPoint
    ) {
        
        id = _id
        name = _name
        address = _address
        distance = _distance
        location = _location
        
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
        location = _location
        
        currentVisitorCount = _currentVisitorCount
        maxVisitorCapacity = _maxVisitorCapacity
        
    }
    
    init(
        id _id: String,
        name _name: String,
        address _address: String,
        location _location: GeoPoint
    ) {
        id = _id
        name = _name
        address = _address
        location = _location
    }
    
    enum CrowdLevel {
        case low
        case medium
        case high
    }
    
    func isFull() -> Bool {
        
        if currentVisitorCount == maxVisitorCapacity {
            return true
        }
        else {
            return false
        }
        
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
