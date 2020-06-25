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

class MyAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var buttonsContainer: MDCCard!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    private var authUI: FUIAuth? = nil
    private var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        buttonsContainer.setShadowElevation(ShadowElevation(8), for: .normal)
        
        //Change the image view to a circle
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
        profileImageView.clipsToBounds = true;
        
        setupFirebaseUI()
        
        //Make sure user is sign in
        guard let user = Auth.auth().currentUser else {
            print("User must be sign in!")
            return
        }
        
        self.user = user
        setupUserScreen()
        
    }
    
    /*
     Setup firebase stuffs use for signing out
     */
    private func setupFirebaseUI(){
        authUI = FUIAuth.defaultAuthUI()!
    }

    /*
     Update the screen to display current user informations
     */
    private func setupUserScreen(){
        self.userNameLabel.text = self.user?.displayName
        self.emailLabel.text = self.user?.email
        
        //Get profile image
        AccountDataManager.getUserProfileImage(user: self.user!){
            image, error in
            
            guard let image = image else {
                self.profileImageView.image = UIImage(named: "no-profile")
                return
            }
            
            self.profileImageView.image = image
            
        }
        
    }

    @IBAction func signOut(_ sender: Any) {
        do{
            try authUI?.signOut()
            
            //Reset notifications after signing out
//            let notificationHandler = NotificationHandler.shared
//            notificationHandler.reset()
//            notificationHandler.create()
//            notificationHandler.start()
            
            self.navigationController?.popViewController(animated: true)
        }catch _ {
            print("Unable to signout")
        }
    }
    
    @IBAction func changeImageTap(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        profileImageView.image = image
        picker.dismiss(animated: true)
        AccountDataManager.setUserProfileImage(user: self.user!, image: image){
            error in
            if error != nil {
                print("Error has occur!")
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
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
