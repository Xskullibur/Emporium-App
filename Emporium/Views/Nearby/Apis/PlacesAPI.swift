//
//  PlacesAPI.swift
//  Emporium
//
//  Created by Xskullibur on 8/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FoursquareAPIClient

class PlacesAPI {
    
    let client: FoursquareAPIClient
    
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
    func getNearbyGroceryStore(lat: Double?, long: Double?, radius: Int?, completionHandler: @escaping([GroceryStore], FoursquareClientError?) -> Void) {
        
        // Set API parameters
        let SUPERMARKET_ID = "52f2ab2ebcbc57f1066b8b46"
        var storeList: [GroceryStore] = []
        var parameter: [String: String] = [
            "categoryId": SUPERMARKET_ID,
            "limit": "50",
        ]
        
        if let radius = radius {
            parameter["radius"] = String(radius)
        }
        
        if let lat = lat, let long = long {
            parameter["ll"] = String(lat) + "," + String(long)
        }
        else {
            parameter["near"] = "Singapore"
        }
        
        // Call API for data
        client.request(path: "venues/search", parameter: parameter) { (result) in
            switch result {
            case let .success(data):
                let jsonResult = JSON(data)
                
                let venueCount = jsonResult["response"]["venues"].count
                for i in 0..<venueCount {
                    let venue = jsonResult["response"]["venues"][i]
                    
                    let store = GroceryStore(
                        id: venue["id"].string!,
                        name: venue["name"].string!,
                        address: venue["location"]["formattedAddress"][0].string!,
                        distance: ((venue["location"]["distance"].double ?? 0) / 1000),
                        latitude: venue["location"]["lat"].double!,
                        logitude: venue["location"]["lng"].double!
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
