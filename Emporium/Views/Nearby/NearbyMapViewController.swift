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
import FirebaseFirestore

protocol StoreSelectedDelegate: class {
    func storeSelected(store: GroceryStore)
}

// MARK: - ViewController
class NearbyMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, StoreSelectedDelegate  {

    // MARK: - Variables
    var locationManager: CLLocationManager?
    var loginManager: LoginManager?
    var storeDataManager = StoreDataManager()
    var queueDataManager = QueueDataManager()
    
    var storeList_lessThan1: [GroceryStore] = []
    var storeList_lessThan2: [GroceryStore] = []
    var storeList_moreThan2: [GroceryStore] = []
    var visitorCountListiners: [ListenerRegistration] = []
    
    var listenerManager = ListenerManager()
    var selectedStore: GroceryStore?
    var queueId: String?
    var currentlyServing: String?
    var queueLength: String?
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var martListFAB: MDCFloatingButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Login
        loginManager  = LoginManager(viewController: self)
        
        // MapView
        self.mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 0
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
    }
    
    // MARK: - IBAction
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
            
        }
        
        // Crowd Level
        let crowdColor = annotation.store.getCrowdLevelColor()
        
        // Custom Marker
        view.markerTintColor = crowdColor
        view.glyphText = String(annotation.store.currentVisitorCount)

        
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
        
        
        // Left Callout
        let pointSize: CGFloat = 24
        let systemFontDesc = UIFont.systemFont(ofSize: pointSize, weight: UIFont.Weight.light).fontDescriptor
        let fractionFontDesc = systemFontDesc.addingAttributes([
            
            UIFontDescriptor.AttributeName.featureSettings: [
                UIFontDescriptor.FeatureKey.featureIdentifier: kFractionsType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kDiagonalFractionsSelector
            ]
            
        ])
        
        
        let leftCalloutView = UIView(frame: CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: 60, height: 60)
        ))
        
        // Label
        let leftLabel = UILabel(frame: CGRect(
            origin: CGPoint(x: 5, y: 0),
            size: CGSize(width: 50, height: 50)
        ))
        leftLabel.textColor = .white
        leftLabel.font = UIFont(descriptor: fractionFontDesc, size: pointSize)
        leftLabel.font = UIFont.boldSystemFont(ofSize: leftLabel.font.pointSize)
        leftLabel.adjustsFontSizeToFitWidth = true
        leftLabel.textAlignment = .right
        leftLabel.text = "\(annotation.store.currentVisitorCount)/\(annotation.store.maxVisitorCapacity)"
        leftLabel.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
        // Left Callout
        leftCalloutView.addSubview(leftLabel)
        leftCalloutView.backgroundColor = crowdColor
        
        // View
        view.leftCalloutAccessoryView = leftCalloutView
        
        return view
        
    }
    
    // MARK: - Data Managers
    
    /// Uses PlacesAPI to get **GroceryStores** based on provided coordinates
    func getStores(lat latitude: Double, long longitude: Double) {
        
        storeDataManager.getStoreByDistance(lat: latitude, long: longitude, radius: 2500, onComplete: { (_storeList) in
            
            // Prep Data
            let storeList = _storeList.sorted(by: { $0.distance! < $1.distance! })
            
            self.storeList_lessThan1 = storeList.filter({ (groceryStore) -> Bool in
                groceryStore.distance! <= 1000
            })
            
            self.storeList_lessThan2 = storeList.filter({ (groceryStore) -> Bool in
                groceryStore.distance! > 1000 && groceryStore.distance! <= 2000
            })
            
            self.storeList_moreThan2 = storeList.filter({ (groceryStore) -> Bool in
                groceryStore.distance! > 2000
            })
        
            // Display and Unload Spinner
            self.addAnnotations()
            
        }) {
            // Error Alert
            let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
            let data = Plist.readPlist(url!)!
            let infoDescription = data["Error Alert"] as! String
            self.showAlert(title: "Oops", message: infoDescription)
        }
        
    }
    
    // MARK: - Custom MapView Functions
    
    /// Create a **StoreAnnotation** and add it into the mapView
    func createAnnotationWithStore(_ store: GroceryStore) {
        let annotation = StoreAnnotation(
            coords: CLLocationCoordinate2D(latitude: store.location.latitude, longitude: store.location.longitude),
            store: store
        )
        
        mapView.addAnnotation(annotation)
    }
    
    /// Remove **StoreAnnotation** with the same **GroceryStore.id** and re-create it
    func updateAnnotationWithStore(_ store: GroceryStore) {

        let annotation = mapView.annotations.first { (annotation) -> Bool in
            
            let annotation = annotation as? StoreAnnotation
            return annotation?.id == store.id
            
        }
        
        if annotation != nil {
            self.mapView.removeAnnotation(annotation!)
        }
        
        createAnnotationWithStore(store)
        
    }
    
    /**
     Create and add **StoreAnnotations** based on:
     
     1. storeList_lessThan1
     2. storeList_lessThan2
     3. storeList_moreThan2
     */
    func addAnnotations() {
        
        // < 1km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan1 {
                
                // Add listiner to update annotation
                let listener = storeDataManager.storeListener(store) { (data) in
                    guard let visitorCount = data["current_visitor_count"] as? Int,
                        let maxCapacity = data["max_visitor_capacity"] as? Int else {
                            print("Field data was empty. (VisitorCount.Listener)")
                            return
                    }
                
                    store.currentVisitorCount = visitorCount
                    store.maxVisitorCapacity = maxCapacity
                    self.updateAnnotationWithStore(store)
                }
                
                listenerManager.add(listener)
                
            }
        }
        
        // < 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan2 {
                
                // Add listiner to update annotation
                let listener = storeDataManager.storeListener(store) { (data) in
                    guard let visitorCount = data["current_visitor_count"] as? Int,
                        let maxCapacity = data["max_visitor_capacity"] as? Int else {
                            print("Field data was empty. (VisitorCount.Listener)")
                            return
                    }
                    
                    store.currentVisitorCount = visitorCount
                    store.maxVisitorCapacity = maxCapacity
                    self.updateAnnotationWithStore(store)
                }
                
                listenerManager.add(listener)
                
            }
        }
        
        // > 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_moreThan2 {
                
                // Add listiner to update annotation
                let listener = storeDataManager.storeListener(store) { (data) in
                    guard let visitorCount = data["current_visitor_count"] as? Int,
                        let maxCapacity = data["max_visitor_capacity"] as? Int else {
                            print("Field data was empty. (VisitorCount.Listener)")
                            return
                    }
                    
                    store.currentVisitorCount = visitorCount
                    store.maxVisitorCapacity = maxCapacity
                    self.updateAnnotationWithStore(store)
                }
                
                listenerManager.add(listener)
                
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
        
        if Auth.auth().currentUser != nil {
            joinQueueAndNavigate(store)
        }
        else {
            loginManager!.setLoginComplete { (user) in
                self.joinQueueAndNavigate(store)
            }
            
            loginManager!.showLoginViewController()
        }
        
    }
    
    func joinQueueAndNavigate(_ store: GroceryStore) {
        if store.getCrowdLevel() == .high {
            let alert = UIAlertController(
                title: "Notice",
                message: "The grocery store is crowded at the moment. Would you like to continue?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.joinQueue(store: store)
            }))
            
            self.present(alert, animated: true)
        }
        else {
            joinQueue(store: store)
        }
    }
    
    func joinQueue(store: GroceryStore) {
        
        // Clear Listeners
        self.listenerManager.clear()
        
        // Show Spinner
        showSpinner(onView: self.view)
        
        // Error Alert
        let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
        let data = Plist.readPlist(url!)!
        let infoDescription = data["Error Alert"] as! String
        
        // Join Queue
        queueDataManager.joinQueue(storeId: store.id, onComplete: { (data) in
            
            // Guard queueId
            guard let queueId = data["queueId"] as? String else {
                self.removeSpinner()
                self.showAlert(title: "Oops!", message: infoDescription)
                return
            }
            
            // Get QueueInfo
            let queueDataManager = QueueDataManager()
            queueDataManager.getQueueInfo(storeId: store.id) { (currentlyServing, queueLength) in
                
                // Remove Spinnter
                self.removeSpinner()
                
                // Navigate to QueueVC
                let queueStoryboard = UIStoryboard(name: "Queue", bundle: nil)
                let queueVC = queueStoryboard.instantiateViewController(identifier: "queueVC") as QueueViewController
                
                queueVC.requested = false
                queueVC.store = store
                queueVC.queueId = queueId
                queueVC.currentlyServing = currentlyServing
                queueVC.queueLength = queueLength
                
                let rootVC = self.navigationController?.viewControllers.first
                self.navigationController?.setViewControllers([rootVC!, queueVC], animated: true)
                
            }
        }) { (error) in
            self.removeSpinner()
            self.showAlert(title: "Oops!", message: infoDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // NearbyList
        if segue.identifier == "ShowNearbyList" {
            let nearbyListVC = segue.destination as! NearbyListViewController
            nearbyListVC.storeSelectDelegate = self
            nearbyListVC.storeList_lessThan1 = storeList_lessThan1
            nearbyListVC.storeList_lessThan2 = storeList_lessThan2
            nearbyListVC.storeList_moreThan2 = storeList_moreThan2
        }
        
    }

}
