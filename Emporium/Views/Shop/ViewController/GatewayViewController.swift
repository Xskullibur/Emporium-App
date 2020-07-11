//
//  GatewayViewController.swift
//  Emporium
//
//  Created by hsienxiang on 21/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import Foundation
import Lottie

class GatewayViewController: UIViewController {
    
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var expDatePickerView: UIPickerView!
    
    @IBOutlet weak var cardAnimation: AnimationView!
    
    var stripePublishableKey = "pk_test_tFCu0UObLJ3OVCTDNlrnhGSt00vtVeIOvM"
    var backendBaseURL: String? = "http://172.27.177.40:5000"
    //local http://192.168.86.1:5000
    //web https://hidden-ridge-68133.herokuapp.com
    //visa credit 4242424242424242 cvc: any 3 number
    //visa debit  4000056655665556
    
    var monthPickerData : [Int] = Array(1...12)
    var yearPickerData: [Int] = Array(2020...2070)
    var labelData: [String] = ["Exp Month", "Exp Year"]
    var cartData: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberInput.placeholder = "Card Number (16 Digit)"
        cvcInput.placeholder = "CVC"
        
        //cardImageView.image = UIImage(named: "noImage")
        
        self.expDatePickerView.dataSource = self
        self.expDatePickerView.delegate = self
        self.expDatePickerView.layer.cornerRadius = 10
        
        self.cardAnimation.animation = Animation.named("cardAni2")
        self.cardAnimation.contentMode = .scaleAspectFit
        self.cardAnimation.loopMode = .loop
        self.cardAnimation.play()
        
        let labelWidth = expDatePickerView.frame.width / CGFloat(expDatePickerView.numberOfComponents)
        for index in 0..<labelData.count {
            let label: UILabel = UILabel.init(frame: CGRect(x: expDatePickerView.frame.origin.x + labelWidth * CGFloat(index), y: 0, width: labelWidth, height: 20))
            label.text = labelData[index]
            label.textAlignment = .center
            expDatePickerView.addSubview(label)
        }
        
       expDatePickerView.layer.borderWidth = 1
       expDatePickerView.layer.borderColor = UIColor.darkText.cgColor
        
    }
    
    func checkPaymentInfo(number: String, cvc: String, month: Int, year: Int) -> [String] {
        var error: [String] = []
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "YYYY"
        let currentYear = format.string(from: date)
        format.dateFormat = "MM"
        let currentMonth = format.string(from: date)
        
        if(String(number.filter { !" \n\t\r".contains($0) }).count != 16) {
            error.append("Card number must have exactily 16 digit\n")
        }
        
        if(Int(number) == nil) {
            error.append("Card number must only contain numbers\n")
        }
        
        if(String(cvc.filter { !" \n\t\r".contains($0) }).count != 3) {
            error.append("CVC must have exactily 3 digit\n")
        }
        
        if(Int(cvc) == nil) {
            error.append("CVC must only contain numbers\n")
        }
        
        if(Int(currentMonth)! >= month) {
            if Int(currentYear)! >= year {
                error.append("Card Expiry Date must be next month or longer\n")
            }
        }
        
        return error
        
    }
    
    @IBAction func paybtnPressed(_ sender: Any) {
        
        var paymentInfo = PaymentInfo()
        
        paymentInfo.cartItems = []
        
        let number = numberInput.text
        let month = monthPickerData[expDatePickerView.selectedRow(inComponent: 0)]
        let year = yearPickerData[expDatePickerView.selectedRow(inComponent: 1)]
        let cvc = cvcInput.text
        var message = ""
        
        let error: [String] = checkPaymentInfo(number: number!, cvc: cvc!, month: month, year: year)
        
        if(error.count == 0) {
            
                self.showSpinner(onView: self.view)
            
                paymentInfo.number = number!
                paymentInfo.month = Int32(month)
                paymentInfo.year = Int32(year)
                paymentInfo.cvc = cvc!
                paymentInfo.userid = Auth.auth().currentUser?.uid as! String
                
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
                        
                        if let data = data, let datastring = String(data:data,encoding: .utf8) {
                            message = datastring
                        }
                        
                        if httpResponse.statusCode == 200 {
                            DispatchQueue.main.async
                            {
                                self.removeSpinner()
                                let showAlert = UIAlertController(title: "Result", message: "Payment Successful", preferredStyle: .alert)
                                let back = UIAlertAction(title: "OK", style: .default) {
                                    action in
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                                showAlert.addAction(back)
                                self.present(showAlert, animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async
                            {
                                self.removeSpinner()
                                let showAlert = UIAlertController(title: "Payment Failed", message: message, preferredStyle: .alert)
                                let cancel = UIAlertAction(title: "OK", style: .cancel)
                                showAlert.addAction(cancel)
                                self.present(showAlert, animated: true, completion: nil)
                            }
                        }
                    }
                }.resume()
        }else{
            var totalError: String = ""
            for err in error {
                totalError = totalError + err
            }
            Toast.showToast(totalError)
        }
    }
        
}

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

