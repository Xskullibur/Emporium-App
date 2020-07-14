//
//  QueueItem.swift
//  Emporium
//
//  Created by Xskullibur on 9/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

class QueueItem: NSObject {
    
    let id: String
    let userId: String
    let date: Date
    let status: QueueStatus
    
    init(id _id: String, userId _userId: String, date _date: Date, status _status: QueueStatus) {
        id = _id
        userId = _userId
        date = _date
        status = _status
    }

    static func hash_id(str: String) -> String {
        
        if str == "-" {
            return str
        }
        else {
            var strToHash = str
            if str.count % 2 != 0 {
                //Is odd, add space
                strToHash += " "
            }
            
            var result: UInt32 = 0

            let utfCodes = strToHash.unicodeScalars
            for i in stride(from: 0, to: strToHash.count, by: 2) {
                let index = strToHash.index(strToHash.startIndex, offsetBy: i)
                let code = utfCodes[index].value << 16 | utfCodes[utfCodes.index(after: index)].value
                result = code ^ result
            }
            return String(format: "%02X", result * 211)
        }
        
    }
    
}
