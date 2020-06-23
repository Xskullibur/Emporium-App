//
//  GatewayViewController.swift
//  Emporium
//
//  Created by user1 on 21/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Stripe
import Alamofire

class GatewayViewController: UIViewController {
    
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var expDatePickerView: UIPickerView!
    
    var stripePublishableKey = "pk_test_tFCu0UObLJ3OVCTDNlrnhGSt00vtVeIOvM"
    var backendBaseURL: String? = "http://192.168.86.1:5000"
    //local http://192.168.86.1:5000
    //web https://hidden-ridge-68133.herokuapp.com
    
    var monthPickerData : [Int] = Array(1...12)
    var yearPickerData: [Int] = Array(2020...2070)
    var labelData: [String] = ["Exp Month", "Exp Year"]
    var cartData: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberInput.placeholder = "Card Number"
        cvcInput.placeholder = "CVC"
        
        cardImageView.image = UIImage(named: "noImage")
        
        self.expDatePickerView.dataSource = self
        self.expDatePickerView.delegate = self
        self.expDatePickerView.layer.cornerRadius = 10
        
        let labelWidth = expDatePickerView.frame.width / CGFloat(expDatePickerView.numberOfComponents)
        for index in 0..<labelData.count {
            let label: UILabel = UILabel.init(frame: CGRect(x: expDatePickerView.frame.origin.x + labelWidth * CGFloat(index), y: 0, width: labelWidth, height: 20))
            label.text = labelData[index]
            label.textAlignment = .center
            expDatePickerView.addSubview(label)
        }
        
    }
    
    @IBAction func paybtnPressed(_ sender: Any) {
        
        var paymentInfo = PaymentInfo()
        
        paymentInfo.cartItems = []
        
        let number = numberInput.text
        let month = monthPickerData[expDatePickerView.selectedRow(inComponent: 0)]
        let year = yearPickerData[expDatePickerView.selectedRow(inComponent: 1)]
        let cvc = cvcInput.text
        
        paymentInfo.number = number!
        paymentInfo.month = Int32(month)
        paymentInfo.year = Int32(year)
        paymentInfo.cvc = cvc!
        
        for cart in cartData {
            var cartItemAdd = CartItem()
            cartItemAdd.productID = cart.productID
            cartItemAdd.quantity = Int32(cart.quantity)
            paymentInfo.cartItems.append(cartItemAdd)
        }
        
        let data = try? paymentInfo.serializedData()
        
        let session  = URLSession.shared
        let url = URL(string: backendBaseURL! + "/oneTimeCharge")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        session.uploadTask(with: request, from: data) {
            data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("success")
                }
            }
            if let data = data, let datastring = String(data:data,encoding: .utf8) {
                print(datastring)
            }
        }.resume()
    }
}
    
//    let number = numberInput.text
//    let month = String(monthPickerData[expDatePickerView.selectedRow(inComponent: 0)])
//    let year = String(yearPickerData[expDatePickerView.selectedRow(inComponent: 1)])
//    let cvc = cvcInput.text
//
//    let cartItem = CartItem()
//
//    let data = try? cartItem.serializedData()
//
//    let session  = URLSession.shared
//    let url = URL(string: backendBaseURL! + "/createToken")
//    var request = URLRequest(url: url!)
//    request.httpMethod = "POST"
//    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
//    let JSON = ["number":number, "month": month, "year": year, "cvc": cvc]
//    let JSONDATA = try! JSONSerialization.data(withJSONObject: JSON, options: [])
//
//    session.uploadTask(with: request, from: data) {
//        data, response, error in
//        if let httpResponse = response as? HTTPURLResponse {
//            if httpResponse.statusCode == 200 {
//                print("success")
//            }
//        }
//        if let data = data, let datastring = String(data:data,encoding: .utf8) {
//            print(datastring)
//        }
//    }.resume()
//}

extension GatewayViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return monthPickerData.count
        }else{
            return yearPickerData.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(monthPickerData[row])
        }else{
            return String(yearPickerData[row])
        }
    }

}
