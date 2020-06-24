//
//  StoreAnnotation.swift
//  Emporium
//
//  Created by Xskullibur on 22/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class StoreAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var store: GroceryStore
    var title: String?
    var subtitle: String?
    
    init(coords _coords: CLLocationCoordinate2D,
         store _store: GroceryStore) {
        
        // Required
        store = _store
        coordinate = _coords
        title = _store.name
        subtitle = _store.address
        
        super.init()
    }
    
    var mapItem: MKMapItem? {
        let addressDict = [CNPostalAddressStreetKey: store.address]
        let placemark = MKPlacemark(
            coordinate: coordinate,
            addressDictionary: addressDict
        )
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = store.name
        
        return mapItem
    }

}
