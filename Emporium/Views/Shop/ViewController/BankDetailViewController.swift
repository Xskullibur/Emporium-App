//
//  BankDetailViewController.swift
//  Emporium
//
//  Created by hsienxiang on 15/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase
import WebKit

class BankDetailViewController: UIViewController {

    @IBOutlet weak var bankInput: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var update: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBankNumber()
    }
    
    func getBankNumber(){
        Payment.getBankNumber() {
            number in
            self.bankInput.text = number
            if number != "" {
                self.saveBtn.setTitle("Update", for: .normal)
                self.update = true
            }else{
                self.saveBtn.setTitle("Save", for: .normal)
                self.update = false
            }
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if bankInput.text == "" {
            alertMessage(message: "Bank Number cannot be empty")
        }else if (String(bankInput.text!.filter { !" \n\t\r".contains($0) }).count != 9 || Int(bankInput.text!) == nil) {
            alertMessage(message: "Bank Number must be 9 digit")
        }else{
            if self.update == false {
                addBankDetails(bankNumber: bankInput.text!)
            }else{
                updateBankDetails(bankNumber: bankInput.text!)
            }
        }
    }
    
    
    @IBAction func testBtnPressed(_ sender: Any) {
        updateVerify()
    }
    
    func alertMessage(message: String) {
        let showAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel)
        showAlert.addAction(cancel)
        self.present(showAlert, animated: true, completion: nil)
    }
    
    
    func addBankDetails(bankNumber: String) {
        self.showSpinner(onView: self.view)
        var message = ""
        
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in
            let session  = URLSession.shared
            let url = URL(string: Global.BACKEND_SERVER_HOST + "/createCustomAccount")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let JSON = ["bankNumber": bankNumber]
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
                                let showAlert = UIAlertController(title: "Result", message: "Redirecting to verification", preferredStyle: .alert)
                                let back = UIAlertAction(title: "OK", style: .default) {
                                    action in
                                    
                                    let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                                    self.view.addSubview(webView)
                                    let url = URL(string: message)
                                    webView.load(URLRequest(url: url!))
                                    
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
                                let showAlert = UIAlertController(title: "Failed", message: message, preferredStyle: .alert)
                                let cancel = UIAlertAction(title: "OK", style: .cancel)
                                showAlert.addAction(cancel)
                                self.present(showAlert, animated: true, completion: nil)
                        }
                    }
                }
            }.resume()
        })
    }
    
    func updateBankDetails(bankNumber: String) {
        self.showSpinner(onView: self.view)
        var message = ""
        
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in
            let session  = URLSession.shared
            let url = URL(string: Global.BACKEND_SERVER_HOST + "/updateCustomAccount")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let JSON = ["bankNumber": bankNumber]
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
                                let showAlert = UIAlertController(title: "Result", message: "Updated Successfully", preferredStyle: .alert)
                                let cancel = UIAlertAction(title: "OK", style: .cancel)
                                showAlert.addAction(cancel)
                                self.present(showAlert, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                            {
                                self.removeSpinner()
                                let showAlert = UIAlertController(title: "Failed", message: message, preferredStyle: .alert)
                                let cancel = UIAlertAction(title: "OK", style: .cancel)
                                showAlert.addAction(cancel)
                                self.present(showAlert, animated: true, completion: nil)
                        }
                    }
                }
            }.resume()
        })
    }
    
    func updateVerify() {
        var message = ""
        
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in
            let session  = URLSession.shared
            let url = URL(string: Global.BACKEND_SERVER_HOST + "/updateVerify")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let JSON = ["bankNumber": "test"]
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
                                //self.removeSpinner()
                                let showAlert = UIAlertController(title: "Result", message: "Redirecting to verification", preferredStyle: .alert)
                                let back = UIAlertAction(title: "OK", style: .default) {
                                    action in
                                    
                                    let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                                    self.view.addSubview(webView)
                                    let url = URL(string: message)
                                    webView.load(URLRequest(url: url!))
                                    
                                }
                                showAlert.addAction(back)
                                self.present(showAlert, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                            {
                                let showAlert = UIAlertController(title: "Failed", message: message, preferredStyle: .alert)
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
