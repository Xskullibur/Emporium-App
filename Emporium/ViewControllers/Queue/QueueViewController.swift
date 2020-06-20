//
//  QueueViewController.swift
//  Emporium
//
//  Created by Xskullibur on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class QueueViewController: UIViewController {

    var justJoinedQueue = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if justJoinedQueue {
            
            let alert = UIAlertController(
                title: "Would you like to volunteer?",
                message: "Volunteer to help your fellow neighbours get groceries",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                let thanksAlert = UIAlertController(
                    title: "Thank you!",
                    message: "You will be notified when there is a request.",
                    preferredStyle: .alert
                )
                thanksAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(thanksAlert, animated: true)
                
            }))
            
            self.present(alert, animated: true)
            
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
