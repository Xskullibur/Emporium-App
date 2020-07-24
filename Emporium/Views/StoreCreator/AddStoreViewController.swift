//
//  AddStoreViewController.swift
//  Emporium
//
//  Created by ITP312Grp1 on 20/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class AddStoreViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Variables
    var store: GroceryStore?
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTxt: MDCTextField!
    @IBOutlet weak var addressTxt: MDCTextField!
    @IBOutlet weak var latitudeTxt: MDCTextField!
    @IBOutlet weak var longitudeTxt: MDCTextField!
    
    
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
