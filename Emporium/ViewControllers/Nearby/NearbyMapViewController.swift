//
//  NearbyMapViewController.swift
//  Emporium
//
//  Created by Xskullibur on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MaterialComponents.MaterialButtons
import FirebaseAuth

protocol StoreSelectedDelegate: class {
    func storeSelected(store: GroceryStore)
}

class StoreButton: UIButton {
    
    var store: GroceryStore?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - ViewController
class NearbyMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, StoreSelectedDelegate  {

    // MARK: - Variables
    var locationManager: CLLocationManager?
    var loginManager: LoginManager?
    var storeList_lessThan1: [GroceryStore] = []
    var storeList_lessThan2: [GroceryStore] = []
    var storeList_moreThan2: [GroceryStore] = []
    var selectedStore: GroceryStore?
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var martListFAB: MDCFloatingButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // MapView
        self.mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 0
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
        // Spinner
        showSpinner(onView: self.view)
    }
    
    @objc func annotationPressed(sender: StoreButton!) {
        storeSelected(store: sender.store!)
    }
    
    // MARK: - MapView
    
    /// Get User Location and Show Nearby Marts
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Get and show user location
        let currentLocation = locations.last!
        
        let region = MKCoordinateRegion (
            center: currentLocation.coordinate,
            latitudinalMeters: 2500,
            longitudinalMeters: 2500
        )
        
        mapView.setRegion(region, animated: true)
        
        // Get Grocery Stores near User
        getStores(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude)
        
    }
    
    /// Custom Annotation
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
            
            // Custom Marker
            view.markerTintColor = annotation.store.getCrowdLevelColor()
            view.glyphText = String(annotation.store.currentVisitorCount)

            
            // Custom Callout
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            
            /// Right Callout
            let rightButton = StoreButton(type: .infoDark)
            rightButton.store = annotation.store
            rightButton.addTarget(self, action: #selector(annotationPressed(sender:)), for: .touchUpInside)
            
            view.rightCalloutAccessoryView = rightButton
            
            let pointSize: CGFloat = 24
            let systemFontDesc = UIFont.systemFont(ofSize: pointSize, weight: UIFont.Weight.light)
                .fontDescriptor
            let fractionFontDesc = systemFontDesc.addingAttributes([
                
                UIFontDescriptor.AttributeName.featureSettings: [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kFractionsType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kDiagonalFractionsSelector
                ]
                
            ])
            
            /// Left Callout
            let leftLabel = UILabel(frame: CGRect(
                origin: CGPoint.zero,
                size: CGSize(width: 48, height: 48)
            ))
            
            leftLabel.font = UIFont(descriptor: fractionFontDesc, size: pointSize)
            leftLabel.adjustsFontSizeToFitWidth = true
            leftLabel.textAlignment = .right
            leftLabel.text = "\(annotation.store.currentVisitorCount)/\(annotation.store.maxVisitorCapacity)"
            
            view.leftCalloutAccessoryView = leftLabel
            view.leftCalloutAccessoryView?.backgroundColor = view.markerTintColor
            
        }
        
        return view
        
    }
    
    // MARK: - Custom MapView Functions
    func getStores(lat latitude: Double, long longitude: Double) {
        
        // Do any additional setup after loading the view.
        let placesAPI = PlacesAPI()
        placesAPI.getNearbyGroceryStore(lat: latitude, long: longitude, radius: 2500, completionHandler: { (_storeList, error) in
            
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
                    // Prep Data
                    let storeList = _storeList.sorted(by: { $0.distance! < $1.distance! })
                    
                    self.storeList_lessThan1 = storeList.filter({ (groceryStore) -> Bool in
                        groceryStore.distance! <= 1
                    })
                    
                    self.storeList_lessThan2 = storeList.filter({ (groceryStore) -> Bool in
                        groceryStore.distance! > 1 && groceryStore.distance! <= 2
                    })
                    
                    self.storeList_moreThan2 = storeList.filter({ (groceryStore) -> Bool in
                        groceryStore.distance! > 2
                    })
                
                    // Display and Unload Spinner
                    self.addAnnotations()
                    self.removeSpinner()
            }

        })
        
    }
    
    func addAnnotations() {
        
        // < 1km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan1 {
                
                let annotation = StoreAnnotation(
                    coords: CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude),
                    store: store
                )
                
                mapView.addAnnotation(annotation)
                
            }
        }
        
        // < 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan2 {
                
                let annotation = StoreAnnotation(
                    coords: CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude),
                    store: store
                )
                
                mapView.addAnnotation(annotation)
                
            }
        }
        
        // > 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_moreThan2 {
                
                let annotation = StoreAnnotation(
                    coords: CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude),
                    store: store
                )
                
                mapView.addAnnotation(annotation)
                
            }
        }
        
        // Shift to user location
        let region = MKCoordinateRegion (
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 2500,
            longitudinalMeters: 2500
        )
        
        mapView.setRegion(region, animated: true)
        
    }
    
    // MARK: - Navigation
    func storeSelected(store: GroceryStore) {
        selectedStore = store
        performSegue(withIdentifier: "ShowQueue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // NearbyList
        if segue.identifier == "ShowNearbyList" {
            let nearbyListVC = segue.destination as! NearbyListViewController
            nearbyListVC.storeList_lessThan1 = storeList_lessThan1
            nearbyListVC.storeList_lessThan2 = storeList_lessThan2
            nearbyListVC.storeList_moreThan2 = storeList_moreThan2
        }
        
        // Queue
        else if segue.identifier == "ShowQueue" {
            let queueVC = segue.destination as! QueueViewController
            queueVC.justJoinedQueue = true
            
            if let store = selectedStore {
                queueVC.store = store
            }
            
        }
        
    }

}
