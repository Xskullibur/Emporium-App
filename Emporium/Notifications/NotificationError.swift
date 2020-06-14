//
//  NotificationError.swift
//  Emporium
//
//  Created by Riyfhx on 11/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

enum EmporiumError : Error {
    //Wrapper around firebase error
    case firebaseError(Error)
}
