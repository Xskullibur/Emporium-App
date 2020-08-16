//
//  LoginManager.swift
//  Emporium
//
//  Created by Peh Zi Heng on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

/**
 Login Manager handles the logic for logining into Firebase
 */
class LoginManager : NSObject, FUIAuthDelegate {
    
    //Firebase UI
    private var authUI: FUIAuth?
    private let viewController: UIViewController!
    
    //Closure called once the login completes
    private var loginComplete: ((User?) -> Void)? = nil
    

    lazy var functions = Functions.functions()
    
    /**
     - Parameters:
        - viewController: To present the login popover view controller
     */
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        self.setupFirebaseLogin()
        self.setupFirebaseFunctions()
    }
    
    /**
     Setup Firebase login
     */
    private func setupFirebaseLogin(){
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self


        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIEmailAuth()
        ]
        self.authUI?.providers = providers
    }
    /**
     Setup Firebase functions
     */
    private func setupFirebaseFunctions(){
        functions.useFunctionsEmulator(origin: Global.FIREBASE_HOST)
    }
    
    /**
     After FirebaseUI login completes
     */
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user{
            //Reset notifications handler so it will listen/get notifications for the correct user
            self.resetNotifications()
            
            //Create user document
            createUserDocument(){
                error in
                if error != nil {
                    print("User document not created, possible that the user document exists!")
                }else{
                    print("Created user document")
                    
                    //resetEarnedRewardsDataManager need to be called here because the 'earned_rewards' document does not exists when the user is just created, we should only called it when the user document is created
                    //If the user already exists we dont have to call resetEarnedRewardsDataManager as the EarnedRewardsDataManager will automatically listen for the correct user
                    
                    //Reset earned rewards data manager so it will listen for the correct user
                    self.resetEarnedRewardsDataManager()
                }
            }
            self.loginComplete?(user)
        }
        self.loginComplete?(user)
    }
    
    /**
     Reset the notifications handler
     */
    func resetNotifications(){
        //Reset notifications
       let notificationHandler = NotificationHandler.shared
       notificationHandler.reset()
       notificationHandler.create()
       notificationHandler.start()
    }
    
    /**
     Reset the rewards data manager
     */
    func resetEarnedRewardsDataManager(){
        let earnedRewardsDataManager = EarnedRewardsDataManager.shared
        earnedRewardsDataManager.listen()
    }
    
    /**
     Callback once the user sign in.
     
     */
    func setLoginComplete(complete: @escaping (User?) -> Void){
        self.loginComplete = complete
    }
    
    /**
     Display the Login page for user to sign in.
     */
    func showLoginViewController(){
        let authViewController = self.authUI!.authViewController()
        self.viewController.present(authViewController, animated: true)
    }
    
    /**
     Call Firebase Functions to create user document
     */
    private func createUserDocument(completion: ((Error?) -> Void)?){
        functions.httpsCallable("createUserIfNotExist").call(){
            result, error in
            
            if let error = error as NSError? {
                completion?(error)
            }
            
            if let status = (result?.data as? [String: Any])?["status"] as? String {
                if status == "Success"{
                    completion?(nil)
                }
                else{
                    completion?(StringError.stringError(status))
                }
            }
            
            
        }
    }
    
}

enum UserType : String{
    case user = "user"
    case merchant = "merchant"
}


extension User {
    
    /**
     Get user type from Firebase
     
    - Note:
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
