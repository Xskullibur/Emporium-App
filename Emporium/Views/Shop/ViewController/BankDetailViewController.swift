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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if bankInput.text != "" {
            addBankDetails(bankNumber: bankInput.text!)
        }
    }
    
    
    func addBankDetails(bankNumber: String) {
        
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
                                //self.removeSpinner()
                                let showAlert = UIAlertController(title: "Result", message: "Verfication Required", preferredStyle: .alert)
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
    
}
