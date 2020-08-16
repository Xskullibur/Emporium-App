//
//  Global.swift
//  Emporium
//
//  Created by Peh Zi Heng on 15/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class Global{
    //STRIPE KEY
    public static let STRIPE_PUBLISHABLE_KEY = "pk_test_tFCu0UObLJ3OVCTDNlrnhGSt00vtVeIOvM"
    
    /// Uncomment as necessary
    
    //MARK: Environment Variables IP
    
    //Emporium backend server host
    public static let BACKEND_SERVER_HOST: String = ProcessInfo.processInfo.environment["backend_server_host"]!
    //Emporium firebase host
    public static let FIREBASE_HOST = ProcessInfo.processInfo.environment["functions_host"]!

    //MARK: END OF Environment Variables IP
    
    
    //MARK: HARDCODED IP

    //Emporium backend server host
    //public static let BACKEND_SERVER_HOST: String = "http://192.168.86.1:5001"
    //Emporium firebase host
    //public static let FIREBASE_HOST = "http://192.168.86.1:5000"

     
    
    //MARK: END OF HARDCODED IP
    
    //local http://192.168.86.1:5000
    //web https://hidden-ridge-68133.herokuapp.com
    //visa credit 4242424242424242 cvc: any 3 number
    //visa debit  4000056655665556
}
