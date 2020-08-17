//
//  MyAccountViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import FirebaseUI
import MaterialComponents.MaterialCards

class MyAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate
{

    // MARK: - Outlets
    @IBOutlet weak var buttonsContainer: MDCCard!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var accountButtonsCollectionView: UICollectionView!
    // MARK: - Variables
    private var authUI: FUIAuth? = nil
    private var user: User?
    
    //Account Reuseable Cell Ids
    private let accountCells = ["PurchaseHistoryCell", "BankCell", "SignOutCell"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Margin for the collection cell
        accountButtonsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        accountButtonsCollectionView.dataSource = self
        accountButtonsCollectionView.delegate = self
        
        //Set shadow for the buttons container
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
            
            //Display error
            if error != nil {
                self.showAlert(title: "Error", message: "Unable to get profile image from the server.")
            }
            
            guard let image = image else {
                self.profileImageView.image = UIImage(named: "no-profile")
                return
            }
            
            self.profileImageView.image = image
            
        }
        
    }

    /**
        Sign out from the current Firebase account
     */
    func signOut() {
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
    
    /**
     When the user taps on their profile image
     */
    @IBAction func changeImageTap(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    /**
     Get the edited image from the image picker to be uploaded onto Firebase Storage
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        profileImageView.image = image
        picker.dismiss(animated: true)
        AccountDataManager.setUserProfileImage(user: self.user!, image: image){
            error in
            if error != nil {
                print("Unable to set user profile image!")
                self.showAlert(title: "Error", message: "Unable to set user profile image.")
            }
        }
        
    }
    /**
     Dismiss picker on cancel
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    ///Change the collections cells base on user type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accountCells.count
    }
    
    ///Change the style of the cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Get cell from reuseable id
        let cell = accountButtonsCollectionView.dequeueReusableCell(withReuseIdentifier: accountCells[indexPath.item], for: indexPath) as! MDCCardCollectionCell

        //Update the UI
        cell.cornerRadius = 13
        cell.contentView.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.setBorderWidth(1, for: .normal)
        cell.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        
        return cell
    }
    
    /// Collection View Selected (Join Queue)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Get reuseable id
        let id = accountCells[indexPath.item]
        
        switch id {
        case "SignOutCell":
            //When the user taps on 'Sign out'
            self.signOut()
            break
        default:
            break
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
