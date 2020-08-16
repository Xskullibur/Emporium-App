//
//  DeliveryAnnotation.swift
//  Emporium
//
//  Created by Xskullibur on 16/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Contacts

class DeliveryAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var address: DeliveryAddress
    
    init(address _address: DeliveryAddress) {
        // Required
        coordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(_address.latitude),
            longitude: CLLocationDegrees(_address.longitude)
        )
        address = _address
        super.init()
    }
    
    var mapItem: MKMapItem? {
        let addressDict = [CNPostalAddressStreetKey: address.address]
        let placemark = MKPlacemark(
            coordinate: coordinate,
            addressDictionary: addressDict
        )
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}
