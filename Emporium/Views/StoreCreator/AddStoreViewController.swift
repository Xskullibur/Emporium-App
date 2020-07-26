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
    @IBOutlet weak var latitudeTxt: MDCTextField!
    @IBOutlet weak var longitudeTxt: MDCTextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Fill data
        if let store = store {
            nameTxt.text = store.name
            addressTxt.text = store.address
            longitudeTxt.text = String(store.location.longitude)
            latitudeTxt.text = String(store.location.latitude)
        }
        
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: Any) {
        
        let uid = Auth.auth().currentUser!.uid
        var storeId: String? = nil
        
        // Guard missing values
        guard let name = nameTxt.text else {
            return
        }
        guard let address = addressTxt.text else {
            return
        }
        guard let latitude = latitudeTxt.text?.doubleValue else {
            return
        }
        guard let longitude = longitudeTxt.text?.doubleValue else {
            return
        }
        if let store = store {
            storeId = store.id
        }
        
        // Add to FireStore
        self.showSpinner(onView: self.view)
        let storeDataManager = StoreDataManager()
        storeDataManager.addStore(id: storeId, name: name, address: address, lat: latitude, long: longitude, merchantId: uid, onComplete:
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
