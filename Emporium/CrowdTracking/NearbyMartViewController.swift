//
//  NearbyMartViewController.swift
//  Emporium
//
//  Created by Xskullibur on 1/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NearbyMartViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    // MARK: - Variables
    var locationManager: CLLocationManager?
    var storeList_lessThan1: [GroceryStore] = []
    var storeList_lessThan2: [GroceryStore] = []
    var storeList_moreThan2: [GroceryStore] = []
    
    var tableSections = ["< 1 km", "< 2 km", "> 2 km"]
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map View
        self.mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 0
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
        // Delegate TableView
        self.tableView.delegate = self
    }
    
    // MARK: - MapView
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.75)
        renderer.lineWidth = 5
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Get and show user location
        let currentLocation = locations.last!
        
        let region = MKCoordinateRegion (
            center: currentLocation.coordinate,
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
        
        mapView.setRegion(region, animated: true)
        
        // Get Grocery Stores near User
        getStores(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude)
        
    }
    
    func showDirections(sourceCoords: CLLocationCoordinate2D, destinationCoords: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) {
        
        // Clear Overlays
        self.mapView.removeOverlays(mapView.overlays)
        
        // Create Direction Request
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoords, addressDictionary: nil))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoords, addressDictionary: nil))
        directionRequest.requestsAlternateRoutes = false
        directionRequest.transportType = transportType
        
        // Request for Direction and Show on Map
        let direction = MKDirections(request: directionRequest)
        direction.calculate { (response, error) in
            guard let unwrappedResponse = response else { return }
            
            let route = unwrappedResponse.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0),
                animated: true
            )
            
        }
        
    }
    
    func getStores(lat latitude: Double, long longitude: Double) {
        
        // Do any additional setup after loading the view.
        let placesAPI = PlacesAPI()
        placesAPI.getNearbyGroceryStore(lat: latitude, long: longitude, radius: 2500, completionHandler: { (_storeList, error) in
            
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
                    let storeList = _storeList.sorted(by: { $0.distance < $1.distance })
                    
                    self.storeList_lessThan1 = storeList.filter({ (groceryStore) -> Bool in
                        groceryStore.distance <= 1
                    })
                    
                    self.storeList_lessThan2 = storeList.filter({ (groceryStore) -> Bool in
                        groceryStore.distance > 1 && groceryStore.distance <= 2
                    })
                    
                    self.storeList_moreThan2 = storeList.filter({ (groceryStore) -> Bool in
                        groceryStore.distance > 2
                    })
            }
            
            self.tableView.reloadData()
            self.addAnnotations()
        })
        
    }
    
    func addAnnotations() {
        
        // < 1km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan1 {
                
                let annotation = MKPointAnnotation()
                annotation.title = store.name
                annotation.subtitle = store.address
                annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                mapView.addAnnotation(annotation)
                
            }
        }
        
        // < 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan2 {
                
                let annotation = MKPointAnnotation()
                annotation.title = store.name
                annotation.subtitle = store.address
                annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                mapView.addAnnotation(annotation)
                
            }
        }
        
        // > 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_moreThan2 {
                
                let annotation = MKPointAnnotation()
                annotation.title = store.name
                annotation.subtitle = store.address
                annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                mapView.addAnnotation(annotation)
                
            }
        }
        
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
            case 0:
                return storeList_lessThan1.count
            case 1:
                return storeList_lessThan2.count
            default:
                return storeList_moreThan2.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let store: GroceryStore

        switch (indexPath.section) {
            case 0:
                store = storeList_lessThan1[indexPath.row]
            case 1:
                store = storeList_lessThan2[indexPath.row]
            default:
                store = storeList_moreThan2[indexPath.row]
        }
        
        cell.textLabel?.text = store.name
        cell.detailTextLabel?.text = "\(String(format: "%.2f", store.distance)) km"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Selected GroceryStore
        let store: GroceryStore

        switch (indexPath.section) {
            case 0:
                store = storeList_lessThan1[indexPath.row]
            case 1:
                store = storeList_lessThan2[indexPath.row]
            default:
                store = storeList_moreThan2[indexPath.row]
        }
        
        // Create Coordinates
        let sourceCoords = CLLocationCoordinate2D(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let destinationCoords = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
        
        // Clear Annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Create Destination Annotation
        let annotation = MKPointAnnotation()
        annotation.title = store.name
        annotation.subtitle = store.address
        annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
        mapView.addAnnotation(annotation)
        
        // Show Directions
        showDirections(sourceCoords: sourceCoords, destinationCoords: destinationCoords, transportType: .walking)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
