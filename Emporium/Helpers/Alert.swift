//
//  Alert.swift
//  Emporium
//
//  Created by Peh Zi Heng on 8/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    /**
     Simple helper for presenting alert to the user
     */
    static func showAlert(title: String, message: String, viewController: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true)
    }
    /**
     Simple helper for asking confirmation from the user
     */
    static func showConfirmation(title: String, message: String, viewController: UIViewController, confirmation: @escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {
            action in
            confirmation()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        viewController.present(alert, animated: true)
    }
    
}

extension UIViewController {
    /**
     Simple helper for presenting alert to the user
     */
    func showAlert(title: String, message: String){
        Alert.showAlert(title: title, message: message, viewController: self)
    }
    
    /**
     Simple helper for asking confirmation from the user
     */
    func showConfirmation(title: String, message: String, confirmation: @escaping () -> Void){
        Alert.showConfirmation(title: title, message: message, viewController: self, confirmation: confirmation)
    }
}
