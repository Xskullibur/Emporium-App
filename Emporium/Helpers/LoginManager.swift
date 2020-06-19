//
//  LoginManager.swift
//  Emporium
//
//  Created by Riyfhx on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

class LoginManager : NSObject, FUIAuthDelegate {
    
    var authUI: FUIAuth?
    private let viewController: UIViewController
    
    private var loginComplete: ((User?) -> Void)? = nil
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        self.setupFirebaseLogin()
    }
    
    private func setupFirebaseLogin(){
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        
        self.authUI?.providers = providers
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
//        guard let user = user else {
//            return
//        }
        
        if user != nil{
            //Reset notifications
            let notificationHandler = NotificationHandler.shared
            notificationHandler.reset()
            notificationHandler.create()
            notificationHandler.start()
        }
        
        
        self.loginComplete?(user)
        
    }
    
    /*
     Callback once the user sign in.
     
     */
    func setLoginComplete(complete: @escaping (User?) -> Void){
        self.loginComplete = complete
    }
    
    /*
     Display the Login page for user to sign in.
     */
    func showLoginViewController(){
        let authViewController = self.authUI!.authViewController()
        self.viewController.present(authViewController, animated: true)
    }
    
    
}
