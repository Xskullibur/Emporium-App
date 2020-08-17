//
//  Payment.swift
//  Emporium
//
//  Created by user1 on 15/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class Payment: NSObject {
    
    static let db = Firestore.firestore()
    
    static func getBankNumber(onComplete: ((String) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).getDocument
        {
            (doc, err) in
            
            var bankNumber: String = ""
            
            if let err = err
            {
                print("Error getting documents: \(err)")
                onComplete?(bankNumber)
            }
            else
            {
                if let doc = doc {
                    
                    if doc.get("accountID") != nil && doc.get("bankID") != nil {
                        bankNumber = doc.get("bankNumber") as! String
                        onComplete?(bankNumber)
                    }
                }
            }
        }
    }
    
    static func checkBank(onComplete: ((Bool) -> Void)?) {
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).getDocument
        {
            (doc, err) in
            
            var exist = false
            
            if let err = err
            {
                print("Error getting documents: \(err)")
                onComplete?(exist)
            }
            else
            {
                if let data = doc?.data() {
                    if data["accountID"] != nil && data["bankID"] != nil {
                        exist = true
                        onComplete?(exist)
                    }
                }
            }
            onComplete?(exist)
        }
    }
    
    static func getOrderExist(onComplete: ((Bool) -> Void)?) {
        let uid = Auth.auth().currentUser!.uid
        
        db.collection("users/\(uid)/order").whereField("received", isEqualTo: "no").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("\(error)")
                onComplete?(false)
                return
            }
            onComplete?(querySnapshot?.isEmpty ?? false)
            
        }
    }
    
    
    
    static func refund(amount: Double, chargeID: String) {
            var message = ""
        
            let refundAmt = String(format: "%.02f", amount)
            
            Auth.auth().currentUser?.getIDToken(completion: {
                token, error in
                let session  = URLSession.shared
                let url = URL(string: Global.BACKEND_SERVER_HOST + "/refund")
                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let JSON = ["amount": refundAmt, "chargeID": chargeID]
                let JSONDATA = try! JSONSerialization.data(withJSONObject: JSON, options: [])
                
                session.uploadTask(with: request, from: JSONDATA) {
                    data, response, error in
                    if let httpResponse = response as? HTTPURLResponse {
                        if let data = data, let datastring = String(data:data,encoding: .utf8) {
                            message = datastring
                        }
                        
                        if httpResponse.statusCode == 200 {
                            DispatchQueue.main.async
                            {
                                print(message)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async
                            {
                                print(message)
                            }
                        }
                    }
                }.resume()
            })
    }
    
    
    
    static func transferVolunteer(amount: Double, accountID: String) {
        
            var message = ""
            let transferAmt = String(format: "%.02f", amount)
            
            Auth.auth().currentUser?.getIDToken(completion: {
                token, error in
                let session  = URLSession.shared
                let url = URL(string: Global.BACKEND_SERVER_HOST + "/transferVolunteer")
                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let JSON = ["amount": transferAmt, "accountID": accountID]
                let JSONDATA = try! JSONSerialization.data(withJSONObject: JSON, options: [])
                
                session.uploadTask(with: request, from: JSONDATA) {
                    data, response, error in
                    if let httpResponse = response as? HTTPURLResponse {
                        if let data = data, let datastring = String(data:data,encoding: .utf8) {
                            message = datastring
                        }
                        
                        if httpResponse.statusCode == 200 {
                            DispatchQueue.main.async
                            {
                                print(message)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async
                            {
                                print(message)
                            }
                        }
                    }
                }.resume()
            })
    }
}
