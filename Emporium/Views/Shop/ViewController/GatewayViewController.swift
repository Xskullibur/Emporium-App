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
import MLKit

class GatewayViewController: UIViewController {
    
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var expDatePickerView: UIPickerView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var showClickLabel: UILabel!
    @IBOutlet weak var cardAnimation: AnimationView!
    
    let scan = Scan()
    var monthPickerData : [Int] = Array(1...12)
    var yearPickerData: [Int] = Array(2020...2070)
    var banks: [String] = []
    var labelData: [String] = ["Exp Month", "Exp Year", "Bank"]
    var cartData: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        banks = scan.getBankList()
        
        numberInput.placeholder = "Card Number (16 Digit)"
        cvcInput.placeholder = "CVC"
        nameInput.placeholder = "Name(Optional)"
        
        
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
        
       self.view.addSubview(cardAnimation)
       let gesture = UITapGestureRecognizer(target: self, action: #selector(self.openScan(_:)))
       self.cardAnimation.addGestureRecognizer(gesture)
       self.cardAnimation.addSubview(showClickLabel)
        
    }
    
    func checkPaymentInfo(number: String, cvc: String, month: Int, year: Int) -> [String] {
        var error: [String] = []
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "YYYY"
        let currentYear = format.string(from: date)
        format.dateFormat = "MM"
        let currentMonth = format.string(from: date)
        
       if(String(number.filter { !" \n\t\r".contains($0) }).count != 16 || Int(number) == nil) {
            error.append("Card number - 16 digits\n")
        }
        
        if(String(cvc.filter { !" \n\t\r".contains($0) }).count != 3 || Int(cvc) == nil) {
            error.append("CVC - 3 digits\n")
        }
        
        if(Int(currentMonth)! >= month) {
            if Int(currentYear)! >= year {
                error.append("Expiry Date - next month or longer\n")
            }
        }
        
        return error
        
    }
    
    @IBAction func paybtnPressed(_ sender: Any) {
        
        var paymentInfo = PaymentInfo()
        
        paymentInfo.order = Order()
        paymentInfo.order.orderByUserID = ""
        
        paymentInfo.order.deliveryAddress = DeliveryAddress()
        paymentInfo.order.deliveryAddress.longitude = 0.0
        paymentInfo.order.deliveryAddress.latitude = 0.0
        paymentInfo.order.deliveryAddress.postal = ""
        paymentInfo.order.deliveryAddress.address = ""
        
        paymentInfo.order.cartItems = []
        
        let number = numberInput.text
        let month = monthPickerData[expDatePickerView.selectedRow(inComponent: 0)]
        let year = yearPickerData[expDatePickerView.selectedRow(inComponent: 1)]
        let cvc = cvcInput.text
        
        let error: [String] = checkPaymentInfo(number: number!, cvc: cvc!, month: month, year: year)
        
        if(error.count == 0) {
            
                self.showSpinner(onView: self.view)
            
                paymentInfo.number = number!
                paymentInfo.month = Int32(month)
                paymentInfo.year = Int32(year)
                paymentInfo.cvc = cvc!
                paymentInfo.bank = ""
                paymentInfo.name = ""
            
                
                for cart in cartData {
                    var cartItemAdd = CartItem()
                    cartItemAdd.productID = cart.productID
                    cartItemAdd.quantity = Int32(cart.quantity)
                    paymentInfo.order.cartItems.append(cartItemAdd)
                }
            
            self.sendPaymentInfo(paymentInfo: paymentInfo)
            
        
        }else{
            var totalError: String = ""
            for err in error {
                totalError = totalError + err
            }
            Toast.showToast(totalError)
        }
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let gallery = UIAlertAction(title: "Choose from gallery", style: .default) {
            action in
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            
            self.present(picker, animated: true)
        }
        
        let scan = UIAlertAction(title: "Camera", style: .default) {
            action in
            
            if !(UIImagePickerController.isSourceTypeAvailable( .camera))
            {
                let showAlert = UIAlertController(title: "Error", message: "Camera not available!", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "OK", style: .cancel)
                showAlert.addAction(cancel)
                self.present(showAlert, animated: true, completion: nil)
                
            }else{
                let picker = UIImagePickerController()
                picker.delegate = self
                
                picker.allowsEditing = true
                picker.sourceType = .camera
                
                self.present(picker, animated: true)
            }
        }
        
        actionSheet.addAction(gallery)
        actionSheet.addAction(scan)
        actionSheet.addAction(cancel)
        
        actionSheet.popoverPresentationController?.sourceRect = self.accessibilityFrame
        actionSheet.popoverPresentationController?.sourceView = self.view
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func openScan(_ send: UITapGestureRecognizer) {
        showActionSheet()
    }
        
    
    private func sendPaymentInfo(paymentInfo: PaymentInfo){
        
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in
            
           let data = try? paymentInfo.serializedData()
               
           let session  = URLSession.shared
           let url = URL(string: Global.BACKEND_SERVER_HOST + "/oneTimeCharge")
           var request = URLRequest(url: url!)
           request.httpMethod = "POST"
           request.setValue("Bearer \(token!)", forHTTPHeaderField:"Authorization")
           request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
           
           var message = ""
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
        })
        
       
    }
    
}

extension GatewayViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return monthPickerData.count
        }else if component == 1{
            return yearPickerData.count
        }else{
            return banks.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       if component == 0 {
            return String(monthPickerData[row])
        }else if component == 1{
            return String(yearPickerData[row])
        }else{
            return String(banks[row])
        }
    }
}

extension GatewayViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        getImageData(imageInput: info[.editedImage] as! UIImage)
        picker.dismiss(animated: true)
    }
    
    func getImageData(imageInput: UIImage) {
        let imageInput = VisionImage(image: imageInput)
        let textRec = TextRecognizer.textRecognizer()
        
        textRec.process(imageInput) {
            result, error in
            
            if error != nil {
                
            }else{
                let resultText = result!.text
                let resultArray = resultText.components(separatedBy: "\n")
                
                let details =  self.scan.extractValue(items: resultArray)
                
                self.numberInput.text = details.cardNumber
                self.expDatePickerView.selectRow(details.month, inComponent: 0, animated: true)
                self.expDatePickerView.selectRow(details.year, inComponent: 1, animated: true)
                self.expDatePickerView.selectRow(details.bank, inComponent: 2, animated: true)
                
                self.nameInput.text = self.scan.extractName(results: resultArray)
                print("Raw result:\n" + resultText + "\n end of raw result")
            }
        }
    }
}
