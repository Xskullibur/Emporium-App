//
//  AddCardViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 29/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class AddCardViewController: UIViewController {
    
    
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var expDatePickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
        
    @IBAction func addBtnPressed(_ sender: Any) {
    }
}
