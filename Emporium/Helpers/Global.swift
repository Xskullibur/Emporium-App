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
    //Emporium backend server host
    public static let BACKEND_SERVER_HOST: String = ProcessInfo.processInfo.environment["backend_server_host"]!
    //local http://192.168.86.1:5000
    //web https://hidden-ridge-68133.herokuapp.com
    //visa credit 4242424242424242 cvc: any 3 number
    //visa debit  4000056655665556
}
