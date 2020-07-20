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

    // MARK: - IBOutlets
    @IBOutlet weak var nameTxt: MDCTextField!
    @IBOutlet weak var addressTxt: MDCTextField!
    @IBOutlet weak var latitudeTxt: MDCTextField!
    @IBOutlet weak var longitudeTxt: MDCTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nxtField = textField.superview?.viewWithTag(textField.tag + 1) as? MDCTextField {
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
