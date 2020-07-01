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
    
    // MARK: - Outlets
    @IBOutlet weak var userBtn: EmporiumCardButton!
    @IBOutlet weak var merchantBtn: EmporiumCardButton!
    
    // MARK: - Variables
    private var loginManager: LoginManager?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        self.loginManager = LoginManager(viewController: self)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Set action listener for both user and merchant card button
        userBtn.update(text: "User", image: UIImage(named: "User")!)
        userBtn.setTapped(loginAction)
        
        merchantBtn.update(text: "Merchant", image: UIImage(named: "Shop")!)
        merchantBtn.setTapped(merchantLoginAction)
        
        //After login completes
        self.loginManager?.setLoginComplete{
            user in
            //Dismiss this view controller after login
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    /**
    When user taps on 'User' login button
     */
    func loginAction() {
        self.loginManager?.setLoginAsUserType(userType: .user)
        self.loginManager?.showLoginViewController()
    }

    /**
    When user taps on 'Merchant' login button
     */
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
