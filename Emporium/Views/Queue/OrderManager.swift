//
//  OrderManager.swift
//  Emporium
//
//  Created by Peh Zi Heng on 25/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase

class OrderManager {
    func test1() {
        Auth.auth().currentUser?.getIDToken(completion: {
        token, error in
            let session  = URLSession.shared
            let url = URL(string: Global.BACKEND_SERVER_HOST + "/test1")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token!)", forHTTPHeaderField:"Authorization")
            
            session.dataTask(with: request, completionHandler: {
                data, response, error in
                if let error = error {
                    print(error)
                }
                
                
                
                }).resume()
            
            
            
        })
    }
}
