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
    
    @IBOutlet weak var userBtn: EmporiumCardButton!
    @IBOutlet weak var merchantBtn: EmporiumCardButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFirebaseLogin()
        
        // Do any additional setup after loading the view.
        
        userBtn.update(text: "User", image: UIImage(named: "User")!)
        userBtn.setTapped(loginAction)
        
        
        merchantBtn.update(text: "Merchant", image: UIImage(named: "Shop")!)
    }
    
    func setupFirebaseLogin(){
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        
        self.authUI?.providers = providers
        

    }
    func loginAction() {
        let authViewController = self.authUI!.authViewController()
        self.present(authViewController, animated: true)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard user != nil else {
            return
        }
        
        //Reset notifications
        let notificationHandler = NotificationHandler.shared
        notificationHandler.reset()
        notificationHandler.create()
        notificationHandler.start()
        
        self.navigationController?.popViewController(animated: true)
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
