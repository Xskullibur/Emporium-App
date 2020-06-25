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

open class LoginManager : NSObject, FUIAuthDelegate {
    
    private var authUI: FUIAuth?
    private let viewController: UIViewController
    
    internal var loginComplete: ((User?) -> Void)? = nil
    
    var loginAsUserType: UserType = .user
    
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        self.setupFirebaseLogin()
    }
    
    private func setupFirebaseLogin(){
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self


        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIEmailAuth()
        ]
        self.authUI?.providers = providers
    }
    
    func setLoginAsUserType(userType: UserType){
        self.loginAsUserType = userType
    }
    
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user{
            self.resetNotifications()
            
            user.getUserType(){
                userType, error in
                
                if userType != nil && userType == self.loginAsUserType{
                    //User have the same user type and login is successful
                    self.loginComplete?(user)
                }else{
                    try? Auth.auth().signOut()
                    Toast.showToast("User is not a \(self.loginAsUserType.rawValue).")
                    print("User type is not correct. Maybe you are trying to login as a merchant when the account is a user or vice versa.")
                }
                
            }
        }
    }
    
    internal func resetNotifications(){
        //Reset notifications
//       let notificationHandler = NotificationHandler.shared
//       notificationHandler.reset()
//       notificationHandler.create()
//       notificationHandler.start()
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

enum UserType : String{
    case user = "user"
    case merchant = "merchant"
}


extension User {
    
    /**
     Get user type from Firebase
     
        Note:
        `completion` may return nil for both UserType and Emporium Error, this means that the user type has not been set inside the Firebase and there is no error.
        This may happen because the user is a new registered user.
     
     */
    func getUserType(completion: @escaping (UserType?, EmporiumError?) -> Void){
        let db = Firestore.firestore()
        
        let userRef = db.document("users/\(self.uid)")
        
        userRef.getDocument{
            document, error in
            
            if let error = error {
                completion(nil, .firebaseError(error))
            }
            
            let type = document?.data()?["type"] as? String ?? ""
            
            if type == "merchant"{
                completion(.merchant, nil)
            }else{
                completion(.user, nil)
            }
            
        }
        
    }
    
}
