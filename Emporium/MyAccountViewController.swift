//
//  MyAccountViewController.swift
//  Emporium
//
//  Created by Riyfhx on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import FirebaseUI
import MaterialComponents.MaterialCards

class MyAccountViewController: UIViewController {

    @IBOutlet weak var buttonsContainer: MDCCard!
    
    var authUI: FUIAuth? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        buttonsContainer.setShadowElevation(ShadowElevation(8), for: .normal)
        
        setupFirebaseUI()
        
    }
    
    func setupFirebaseUI(){
        authUI = FUIAuth.defaultAuthUI()!
    }
    

    @IBAction func signOut(_ sender: Any) {
        do{
            try authUI?.signOut()
            
            //Reset notifications after signing out
            let notificationHandler = NotificationHandler.shared
            notificationHandler.reset()
            notificationHandler.create()
            notificationHandler.start()
            
            self.navigationController?.popViewController(animated: true)
        }catch _ {
            print("Unable to signout")
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
