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
    
    static func showAlert(title: String, message: String, viewController: UIViewController, onComplete: ((UIAlertAction) -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: onComplete))
        
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
    
    func showAlert(title: String, message: String, onComplete: @escaping () -> Void){
        Alert.showAlert(title: title, message: message, viewController: self) { (_) in
            onComplete()
        }
    }
    
}
