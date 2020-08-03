//
//  AddStoreViewController.swift
//  Emporium
//
//  Created by ITP312Grp1 on 20/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import FirebaseAuth
import MaterialComponents.MaterialButtons

extension String {
    struct NumFormatter {
     static let instance = NumberFormatter()
    }

    var doubleValue: Double? {
     return NumFormatter.instance.number(from: self)?.doubleValue
    }

    var integerValue: Int? {
     return NumFormatter.instance.number(from: self)?.intValue
    }
}

class AddStoreViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Variables
    var store: GroceryStore?
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTxt: MDCTextField!
    @IBOutlet weak var addressTxt: MDCTextField!
    @IBOutlet weak var postalTxt: MDCTextField!
    @IBOutlet weak var maxCapacityTxt: MDCTextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Fill data
        if let store = store {
            nameTxt.text = store.name
            addressTxt.text = store.address
            
            if let postal = store.postal {
                postalTxt.text = postal
            }
            
        }
        
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: Any) {
        
        let uid = Auth.auth().currentUser!.uid
        
        // Guard Values
        guard let name = nameTxt.text else {
            self.showAlert(title: "Missing", message: "Name Not Found")
            return
        }
        guard let address = addressTxt.text else {
            self.showAlert(title: "Missing", message: "Address Not Found")
            return
        }
        guard let capacityTxt = maxCapacityTxt.text else {
            self.showAlert(title: "Missing", message: "Max Capacity Not Found")
            return
        }
        guard let maxCapacity: Int = Int(capacityTxt) else {
            self.showAlert(title: "Missing", message: "Invalid Capacity")
            return
        }
        
        if let store = store {
        
            // From Map
            
            /// Add to FireStore
            self.showSpinner(onView: self.view)
            let storeDataManager = StoreDataManager()
            storeDataManager.addStore(id: store.id, name: name, address: address, lat: store.location.latitude, long: store.location.latitude, merchantId: uid, maxCapacity: maxCapacity, onComplete:
            {
                self.removeSpinner()
                
                let alert = UIAlertController(title: "Success", message: "Successfully added store!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    let VCs = self.navigationController!.viewControllers
                    self.navigationController?.popToViewController(VCs[VCs.count - 3], animated: true)
                }))
                
                self.present(alert, animated: true)
                
            }) { (errorMsg) in
                
                self.removeSpinner()
                self.showAlert(title: "Error", message: errorMsg)
                
            }
            
        }
        else {
            // From Manual
            guard let postal = postalTxt.text else {
                self.showAlert(title: "Missing", message: "Postal Code Not Found")
                return
            }
            
            // GeoCode Postal Code
            GeocoderHelper.geocodePostal(postalCode: postal) { (coordinates) in
                guard let coords = coordinates else {
                    self.showAlert(title: "Error", message: "Invalid Postal Code")
                    return
                }
                
                let latitude = coords.latitude
                let longitude = coords.longitude
                
                // Add to FireStore
                self.showSpinner(onView: self.view)
                let storeDataManager = StoreDataManager()
                storeDataManager.addStore(id: nil, name: name, address: address, lat: latitude, long: longitude, merchantId: uid, maxCapacity: maxCapacity, onComplete:
                {
                    self.removeSpinner()
                    
                    let alert = UIAlertController(title: "Success", message: "Successfully added store!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                        let VCs = self.navigationController!.viewControllers
                        self.navigationController?.popToViewController(VCs[VCs.count - 3], animated: true)
                    }))
                    
                    self.present(alert, animated: true)
                    
                }) { (errorMsg) in
                    
                    self.removeSpinner()
                    self.showAlert(title: "Error", message: errorMsg)
                    
                }
                
            }
        }
        
    }
    
    // MARK: - Custom Function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nxtField = self.view.viewWithTag(textField.tag + 1) as? MDCTextField {
            nxtField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return false
        
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
