//
//  VolunteerHelper.swift
//  Emporium
//
//  Created by Xskullibur on 17/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import UIKit

class VolunteerHelper {
    
    static func showVolunteerAlert(viewController: UIViewController, store: GroceryStore, onComplete: @escaping(Order?) -> Void) {
        
        let alert = UIAlertController(
            title: "Would you like to volunteer?",
            message: "Volunteer to help your fellow neighbours get groceries",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {_ in
            onComplete(nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            
            
            //Send delivery request to server
            DeliveryDataManager.checkVolunteerRequest(storeId: store.id, receiveOrder: {
                order in
                if let order = order {
                    
                    // Update Delivery to In Queue
                    DeliveryDataManager.shared.updateDeliveryStatus(status: .in_queue)
                    
                    // Show Local Notification
                    let content = LocalNotificationHelper.createNotificationContent(
                        title: "Volunteer Alert",
                        body: "Someone has requested you to help get groceries!",
                        subtitle: "", others: nil
                    )
                    LocalNotificationHelper.addNotification(
                        identifier: "Order.notification",
                        content: content
                    )
                    
                    // Callback
                    onComplete(order)
                    
                }
            })
            //Start Background fetch
            //            UserDefaults.standard.set(self.store!.id, forKey: "com.emporium.requestOrder:storeId")
            //            (UIApplication.shared.delegate as! AppDelegate).scheduleFetchOrder()
            
            let thanksAlert = UIAlertController(
                title: "Thank you!",
                message: "We will notify you when there is a request.",
                preferredStyle: .alert
            )
            thanksAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                action in
                Payment.checkBank(onComplete: { (exist) in
                    if(!exist){
                        let baseSB = UIStoryboard(name: "Shop", bundle: nil)
                        let vc = baseSB.instantiateViewController(identifier: "bankVC") as! BankDetailViewController
                        viewController.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }))
            viewController.present(thanksAlert, animated: true)
            
        }))
        
        viewController.present(alert, animated: true)
    }
    
}

extension UIViewController {
    func showVolunteerAlert(store: GroceryStore, onComplete: @escaping (Order?) -> Void) {
        VolunteerHelper.showVolunteerAlert(viewController: self, store: store, onComplete: onComplete)
    }
}
