//
//  GeocoderHelper.swift
//  Emporium
//
//  Created by Peh Zi Heng on 27/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts
import Firebase

class GeocoderHelper {
    /**
     Get the address GeoPoint
     If multiple places are returned, it will only get the first place
     */
    static func geocodeAddress(rawAddress: String, completion: @escaping (GeoPoint?) -> Void){
        CLGeocoder().geocodeAddressString(rawAddress, completionHandler: {
            places, error in
            guard let places = places else{
                completion(nil)
                return
            }
            
            let place = places[0]
            completion(GeoPoint(latitude: place.location!.coordinate.latitude, longitude: place.location!.coordinate.longitude))
        })
    }
    
    /**
     Get the postal code GeoPoint
     */
    static func geocodePostal(postalCode: String, completion: @escaping (GeoPoint?) -> Void){
        let postalAddress = CNMutablePostalAddress()
        postalAddress.postalCode = postalCode
        CLGeocoder().geocodePostalAddress(postalAddress, completionHandler: {
            places, error in
            guard let places = places else{
                completion(nil)
                return
            }
            
            let place = places[0]
            completion(GeoPoint(latitude: place.location!.coordinate.latitude, longitude: place.location!.coordinate.longitude))
        })
    }
}
