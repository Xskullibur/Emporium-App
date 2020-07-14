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
            
            result = result * 211
            
            let byte1 = UInt8(result & 0x000000FF)
            let byte2 = UInt8((result & 0x0000FF00) >> 8)
            let byte3 = UInt8((result & 0x00FF0000) >> 16)
            let byte4 = UInt8((result & 0xFF000000) >> 24)

            let byteArray = Data([byte1, byte2, byte3, byte4])
            return byteArray.base64EncodedString().replacingOccurrences(of: "=", with: "", options: NSString.CompareOptions.literal, range: nil)
            
        }
        
    }
    
}
