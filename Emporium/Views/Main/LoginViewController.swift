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
    
    @IBOutlet weak var userBtn: EmporiumCardButton!
    @IBOutlet weak var merchantBtn: EmporiumCardButton!
    
    private var loginManager: LoginManager?
    
    override func viewDidLoad() {
        self.loginManager = LoginManager(viewController: self)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        userBtn.update(text: "User", image: UIImage(named: "User")!)
        userBtn.setTapped(loginAction)
        
        merchantBtn.update(text: "Merchant", image: UIImage(named: "Shop")!)
        merchantBtn.setTapped(merchantLoginAction)
        
        self.loginManager?.setLoginComplete{
            user in
            //Dismiss this view controller after login
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    
    func loginAction() {
        self.loginManager?.setLoginAsUserType(userType: .user)
        self.loginManager?.showLoginViewController()
    }

    
    func merchantLoginAction() {
        self.loginManager?.setLoginAsUserType(userType: .merchant)
        self.loginManager?.showLoginViewController()
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
