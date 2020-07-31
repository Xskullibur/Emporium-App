//
//  AddAddressViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 31/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class AddOrEditAddressViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var addressNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var postalTextField: UITextField!
    
    //MARK: - For editing existing address
    private var editAddress: Address?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let editAddress = self.editAddress {
            self.addressNameTextField.text = editAddress.name
            self.addressTextField.text = editAddress.address
            self.postalTextField.text = editAddress.postal
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onAddOrEditAddressPressed))
            let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(onDeletePressed))
            deleteButton.tintColor = .red
            navigationItem.rightBarButtonItems = [deleteButton, editButton]
        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onAddOrEditAddressPressed))
        }
    }
    
    @objc func onAddOrEditAddressPressed() {
        
        guard let addressName = addressNameTextField.text else {
            self.showAlert(title: "Incomplete field", message: "No address name!")
            return
        }
        guard let address = addressTextField.text else {
            self.showAlert(title: "Incomplete field", message: "No address given")
            return
        }
        guard let postal = postalTextField.text else {
            self.showAlert(title: "Incomplete field", message: "No postal given")
            return
        }
        
        
        GeocoderHelper.geocodePostal(postalCode: postal, completion: {
            geoPoint in
            guard let geoPoint = geoPoint else {
                self.showAlert(title: "Incomplete field", message: "Postal location not found")
                return
            }

            if let editAddress = self.editAddress{
                let updatedAddress = Address(location: geoPoint, postal: postal, address: address, name: addressName)
                AccountDataManager.updateUserAddresses(user: Auth.auth().currentUser!, address_id:editAddress.id!, address: updatedAddress)
            }else{
                AccountDataManager.addUserAddresses(user: Auth.auth().currentUser!,
                address: Address(location: geoPoint, postal: postal, address: address, name: addressName))
            }
            
            self.navigationController?.popViewController(animated: true)
        })
        

    }
    
    @objc func onDeletePressed(){
        guard let editAddress = self.editAddress else {
            return
        }
        
        AccountDataManager.deleteUserAddresses(user: Auth.auth().currentUser!, address: editAddress)
        self.navigationController?.popViewController(animated: true)
    }
    
    /**
     Set the address to be displayed
     */
    func setAddress(_ address: Address){
        self.editAddress = address
        self.title = "Edit Delivery Address"
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
