//
//  MartDetailsViewController.swift
//  Emporium
//
//  Created by Xskullibur on 15/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class MartDetailsViewController: UIViewController {

    var groceryStore: GroceryStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if groceryStore != nil {
            print("\nPAASS\n")
        }
        else {
            print("\nFAIL\n")
        }
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
