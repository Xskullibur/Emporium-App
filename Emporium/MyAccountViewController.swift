//
//  MyAccountViewController.swift
//  Emporium
//
//  Created by Riyfhx on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards

class MyAccountViewController: UIViewController {

    @IBOutlet weak var buttonsContainer: MDCCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        buttonsContainer.setShadowElevation(ShadowElevation(8), for: .normal)
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
