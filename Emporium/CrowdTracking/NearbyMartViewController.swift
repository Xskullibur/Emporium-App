//
//  NearbyMartViewController.swift
//  Emporium
//
//  Created by Xskullibur on 1/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Mapbox

class NearbyMartViewController: UIViewController, MGLMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Variables
    var storeList_lessThan1: [GroceryStore] = []
    var storeList_lessThan2: [GroceryStore] = []
    var storeList_moreThan2: [GroceryStore] = []
    
    var tableSections = ["< 1 km", "< 2 km", "> 2 km"]
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate Map View
        self.mapView.delegate = self
        
        // Map View User Tracking
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserLocation = true
        
        // Delegate TableView
        self.tableView.delegate = self
        
        // Do any additional setup after loading the view.
        let placesAPI = PlacesAPI()
        placesAPI.getNearbyGroceryStore(lat: 1.379907, long: 103.849077, radius: 2500, completionHandler: { (_storeList, error) in
            
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
    
    // MARK: - MapView
    func addAnnotations() {
        
        // < 1km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan1 {
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                annotation.title = store.name
                annotation.subtitle = store.address
                mapView.addAnnotation(annotation)
            }
        }
        
        // < 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_lessThan2 {
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                annotation.title = store.name
                annotation.subtitle = store.address
                mapView.addAnnotation(annotation)
            }
        }
        
        // > 2km Stores
        if !storeList_lessThan1.isEmpty {
            for store in storeList_moreThan2 {
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                annotation.title = store.name
                annotation.subtitle = store.address
                mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        true
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
        let store: GroceryStore

        switch (indexPath.section) {
            case 0:
                store = storeList_lessThan1[indexPath.row]
            case 1:
                store = storeList_lessThan2[indexPath.row]
            default:
                store = storeList_moreThan2[indexPath.row]
        }
        
        let location = CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
        let camera = MGLMapCamera(lookingAtCenter: location, acrossDistance: 450, pitch: 15, heading: 180)
        mapView.fly(to: camera, completionHandler: nil)
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
