//
//  LoginViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 1/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class LoginViewController: UIViewController, FUIAuthDelegate {

    var authUI: FUIAuth?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFirebaseLogin()
        
        // Do any additional setup after loading the view.
    }
    
    func setupFirebaseLogin(){
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        
        self.authUI?.providers = providers
        

    }
    
    @IBAction func loginAction(_ sender: Any) {
        let authViewController = self.authUI!.authViewController()
        self.present(authViewController, animated: true)
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
