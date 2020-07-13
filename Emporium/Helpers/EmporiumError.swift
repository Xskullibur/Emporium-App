//
//  NotificationError.swift
//  Emporium
//
//  Created by Peh Zi Heng on 11/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

enum EmporiumError : Error {
    //Wrapper around firebase error
    case firebaseError(Error)
    //Wrapper around NSError error
    case nserror(NSError)
    
    case error(String)
}

enum StringError : Error {
    case stringError(String)
    
    /**
     Returns a String representation of the error
     */
    func get() -> String{
        switch self {
        case .stringError(let errorStr):
            return errorStr
        }
    }
    
}
