//
//  StoreSelectViewController.swift
//  Emporium
//
//  Created by ITP312Grp1 on 24/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StoreSelectViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Variables
    var selectedStore: GroceryStore?
    var locationManager = CLLocationManager()
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        showSpinner(onView: self.view)
        
        let placesAPI = PlacesAPI()
        placesAPI.getNearbyGroceryStore(lat: nil, long: nil, radius: nil, completionHandler: { (_storeList, error) in
            
            self.removeSpinner()
            
            #warning("TODO: - Handle Errors")
            // TODO: - Handle Errors
            switch error {
                case let .connectionError(connectionError):
                    print(connectionError)
                    
                case let .responseParseError(responseParseError):
                    print(responseParseError)   // e.g. JSON text did not start with array or object and option to allow fragments not set.
                    
                case let .apiError(apiError):
                    print(apiError.errorType)   // e.g. endpoint_error
                    print(apiError.errorDetail) // e.g. The requested path does not exist.
                    
                case .none:
                    for store in _storeList {
                        let annotation = StoreAnnotation(
                            coords: CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude),
                            store: store
                        )
                        self.mapView.addAnnotation(annotation)
                    }
                
            }

        })
        
    }
    
    // MARK: - Map View
    @objc func annotationPressed(sender: StoreButton!) {
        selectedStore = sender.store!
        self.performSegue(withIdentifier: "showStoreEdit", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check for custom annotaion
        guard let annotation = annotation as? StoreAnnotation else {
            return nil
        }
        
        let identifier = annotation.store.id
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            
            // Return if Annotation Exist
            dequeuedView.annotation = annotation
            view = dequeuedView
            
        }
        else {
            
            // Create Annotation if Not Found
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier
            )
            
        }
        
        // Custom Callout
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        
        /// Right Callout
        let rightButton = StoreButton(frame:
            CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15))
        )
        rightButton.setImage(UIImage(named: "next"), for: .normal)
        rightButton.contentMode = .scaleAspectFit
        rightButton.store = annotation.store
        rightButton.addTarget(self, action: #selector(annotationPressed(sender:)), for: .touchUpInside)
        
        view.rightCalloutAccessoryView = rightButton
        
        return view
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStoreEdit" {
            let addStoreVC = segue.destination as! AddStoreViewController
            addStoreVC.store = selectedStore
        }
    }

}
