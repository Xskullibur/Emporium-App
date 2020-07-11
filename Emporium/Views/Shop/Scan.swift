//
//  Scan.swift
//  Emporium
//
//  Created by hsienxiang on 11/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Foundation
import MLKit

class Scan {
    
    var cardNumber: String = ""
    var month: Int = 0
    var year: Int = 0
    var bank: Int = 0
    var name: String = ""
    let banks: [String] = ["Others", "POSB", "DBS", "OCBC", "UOB"]
    
    //name
    func extractName(results: [String]) -> String{
        let notName: [String] = ["mastercard", "visa", "signature"]
        let pattern = "^[a-zA-Z\\s]*$"
        for index in stride(from: results.count - 1, to: 0, by: -1) {
            let isLetter = results[index].range(of: pattern, options: .regularExpression)
            if isLetter != nil {
                if !notName.contains(results[index].lowercased()) {
                    return results[index]
                }
            }
        }
        return ""
    }
    //name
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    func extractValue(items : [String]) -> ScanDetail {
        
        for item in items {
            let noWhiteSpace = String(item.filter { !" \n\t\r".contains($0)})
            
            //bank
            for brand in banks{
                if noWhiteSpace.contains(brand) {
                    let row = banks.firstIndex(of: brand)
                    bank = row!
                    break
                }
            }
            //bank
            
            //number
            let number = noWhiteSpace.filter("0123456789".contains)
            if number.count == 16 {
                let pattern = "\\d{16}"
                let result = noWhiteSpace.range(of: pattern, options: .regularExpression)
                
                if result != nil {
                    print(noWhiteSpace)
                    cardNumber = noWhiteSpace
                }
            }else{
                var alternateNumber = noWhiteSpace.filter("0123456789sSbBL".contains)
                
                if 14...16 ~= alternateNumber.count {
                    alternateNumber = alternateNumber.replacingOccurrences(of: "s", with: "5")
                    alternateNumber = alternateNumber.replacingOccurrences(of: "S", with: "5")
                    alternateNumber = alternateNumber.replacingOccurrences(of: "b", with: "6")
                    alternateNumber = alternateNumber.replacingOccurrences(of: "L", with: "6")
                    alternateNumber = alternateNumber.replacingOccurrences(of: "B", with: "8")
                    
                    cardNumber = alternateNumber
                    print("alternate number \(alternateNumber)")
                }
            }
            //number
            
            //date
            if noWhiteSpace.contains("/") {
                let date = noWhiteSpace.filter("0123456789/".contains)
                let dateArray = date.components(separatedBy: "/")
                
                if dateArray[0] != "" {
                    if 0...12 ~= Int(dateArray[0])! {
                        month = Int(dateArray[0])! - 1
                    }
                }
                
                if dateArray[1] != "" {
                    if 20...70 ~= Int(dateArray[1])! {
                        year = Int(dateArray[1])! - 20
                    }
                }
                
                print(date)
            }else{
                var alternateDate = noWhiteSpace.filter("0123456789".contains)
                
                if alternateDate.count == 5 {
                    alternateDate = self.replace(myString: alternateDate, 2, "/")
                    
                    let dateArray = alternateDate.components(separatedBy: "/")
                    
                    if dateArray[0] != "" {
                        if 0...12 ~= Int(dateArray[0])! {
                            month = Int(dateArray[0])! - 1
                        }
                    }
                    
                    if dateArray[1] != "" {
                        if 20...70 ~= Int(dateArray[1])! {
                            year = Int(dateArray[1])! - 20
                        }
                    }
                }
                
                print(alternateDate)
            }
        }
        return ScanDetail(number: cardNumber, month: month, year: year, bank: bank, name: "")
    }
    
    func getBankList() -> [String] {
        return banks
    }
    
}
