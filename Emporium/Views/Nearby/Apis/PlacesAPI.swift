//
//  PlacesAPI.swift
//  Emporium
//
//  Created by Xskullibur on 8/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FoursquareAPIClient
import FirebaseFirestore

class PlacesAPI {
    
    let client: FoursquareAPIClient
    var parameters = [
        "categoryId": "52f2ab2ebcbc57f1066b8b46",       // Supermarket ID
        "limit": "50"
    ]
    
    // MARK: - Init
    init() {
        
        /// Get Data.plist (PlacesAPI ClientID and Secret)
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        var plistData: [String: AnyObject] = [:]
        let plistPath: String? = Bundle.main.path(forResource: "Data", ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do {
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]
        } catch {
            print("Error reading plist: \(error), format: \(propertyListFormat)")
        }
        
        let CLIENT_ID = plistData["PlacesAPI ID"] as! String
        let CLIENT_SECRET = plistData["PlacesAPI Secret"] as! String
        
        /// Define Client
        client = FoursquareAPIClient(clientId: CLIENT_ID, clientSecret: CLIENT_SECRET)
        
    }
    
    // MARK: - Functions
    func getNearbyGroceryStore(near _near: String?, radius _radius: Int?, completionHandler: @escaping([GroceryStore], FoursquareClientError?) -> Void) {
        
        var storeList: [GroceryStore] = []
        
        // radius
        if let radius = _radius {
            parameters["radius"] = String(radius)
        }
        
        // near
        if let near = _near {
            parameters["near"] = near
            parameters["radius"] = "2500"
        }
        else {
            parameters["near"] = "Singapore"
        }
        
        client.request(path: "venues/search", parameter: parameters) { (result) in
            switch result {
            case let .success(data):
                let jsonResult = JSON(data)
                
                let venueCount = jsonResult["response"]["venues"].count
                for i in 0..<venueCount {
                    let venue = jsonResult["response"]["venues"][i]
                    
                    let location = GeoPoint(
                        latitude: venue["location"]["lat"].double!,
                        longitude: venue["location"]["lng"].double!
                    )
                    
                    let store = GroceryStore(
                        id: venue["id"].string!,
                        name: venue["name"].string!,
                        address: venue["location"]["formattedAddress"][0].string!,
                        distance: ((venue["location"]["distance"].double ?? 0) / 1000),
                        location: location
                    )
                    
                    storeList.append(store)
                }
                
                completionHandler(storeList, .none)
            
            case let .failure(error):
                completionHandler(storeList, error)

            }
        }
        
    }
    
    func getNearbyGroceryStore(lat: Double, long: Double, radius: Int?, completionHandler: @escaping([GroceryStore], FoursquareClientError?) -> Void) {
        
        // Set API parameters
        var storeList: [GroceryStore] = []
        parameters["ll"] = String(lat) + "," + String(long)
        
        if let radius = radius {
            parameters["radius"] = String(radius)
        }
        
        // Call API for data
        client.request(path: "venues/search", parameter: parameters) { (result) in
            switch result {
            case let .success(data):
                let jsonResult = JSON(data)
                
                let venueCount = jsonResult["response"]["venues"].count
                for i in 0..<venueCount {
                    let venue = jsonResult["response"]["venues"][i]
                    
                    let location = GeoPoint(
                        latitude: venue["location"]["lat"].double!,
                        longitude: venue["location"]["lng"].double!
                    )
                    
                    let store = GroceryStore(
                        id: venue["id"].string!,
                        name: venue["name"].string!,
                        address: venue["location"]["formattedAddress"][0].string!,
                        distance: ((venue["location"]["distance"].double ?? 0) / 1000),
                        location: location
                    )
                    
                    storeList.append(store)
                }
                
                completionHandler(storeList, .none)
            
            case let .failure(error):
                completionHandler(storeList, error)

            }
        }
    }
}
