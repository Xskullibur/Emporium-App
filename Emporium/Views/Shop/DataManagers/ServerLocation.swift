//
//  serverLocation.swift
//  Emporium
//
//  Created by user1 on 14/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Foundation

class ServerLocation: NSObject {
    
    static func getLocation() -> String
    {
        let web = "https://hidden-ridge-68133.herokuapp.com"
        let home = "http://192.168.86.1:5001"
        //http://172.27.177.40:5001
        return home
    }
}


