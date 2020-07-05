//
//  AddCardViewController.swift
//  Emporium
//
//  Created by hsienxiang on 29/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie
import Firebase

class AddCardViewController: UIViewController {
    
    
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var expDatePickerView: UIPickerView!
    
    @IBOutlet weak var cardAnimation: AnimationView!
    
    var backendBaseURL: String? = "http://172.27.177.40:5000" //school
    
    var monthPickerData : [Int] = Array(1...12)
    var yearPickerData: [Int] = Array(2020...2070)
    var labelData: [String] = ["Exp Month", "Exp Year"]
    var cartData: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberInput.placeholder = "Card Number (16 Digit)"
        cvcInput.placeholder = "CVC"
        
        //startAnimation
        self.cardAnimation.animation = Animation.named("cardAni2")
        self.cardAnimation.contentMode = .scaleAspectFit
        self.cardAnimation.loopMode = .loop
        self.cardAnimation.play()
        
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
        
        expDatePickerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        expDatePickerView.layer.shadowColor = UIColor.darkGray.cgColor
        expDatePickerView.layer.shadowRadius = 5
        expDatePickerView.layer.shadowOpacity = 0.9
        expDatePickerView.layer.masksToBounds = false
        expDatePickerView.clipsToBounds = false
    }
        
    @IBAction func addBtnPressed(_ sender: Any) {
        
            let number = numberInput.text
            let month = String(monthPickerData[expDatePickerView.selectedRow(inComponent: 0)])
            let year = String(yearPickerData[expDatePickerView.selectedRow(inComponent: 1)])
            let cvc = cvcInput.text
            let userID = Auth.auth().currentUser?.uid as! String
            var message = ""
        
            let error: [String] = checkPaymentInfo(number: number!, cvc: cvc!, month: Int(month)!, year: Int(year)!)
        
            if error.count == 0 {
                self.showSpinner(onView: self.view)
                
                    let session  = URLSession.shared
                    let url = URL(string: backendBaseURL! + "/createCard")
                    var request = URLRequest(url: url!)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let JSON = ["number":number, "month": month, "year": year, "cvc": cvc, "userid": userID]
                    let JSONDATA = try! JSONSerialization.data(withJSONObject: JSON, options: [])
                
                    session.uploadTask(with: request, from: JSONDATA) {
                        data, response, error in
                        if let httpResponse = response as? HTTPURLResponse {
                            if let data = data, let datastring = String(data:data,encoding: .utf8) {
                                message = datastring
                            }
                            
                            if httpResponse.statusCode == 200 {
                                DispatchQueue.main.async
                                {
                                    self.removeSpinner()
                                    let showAlert = UIAlertController(title: "Result", message: "Card added successfully", preferredStyle: .alert)
                                    let back = UIAlertAction(title: "OK", style: .default) {
                                        action in
                                        self.navigationController?.popViewController(animated: true)
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
                                    let showAlert = UIAlertController(title: "Card not added", message: message, preferredStyle: .alert)
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
}

extension AddCardViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
