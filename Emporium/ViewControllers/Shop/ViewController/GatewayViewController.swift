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
    
    
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var monthInput: UITextField!
    @IBOutlet weak var yearInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    
    
    var stripePublishableKey = "pk_test_tFCu0UObLJ3OVCTDNlrnhGSt00vtVeIOvM"
    var backendBaseURL: String? = "http://192.168.86.1:5000"
    //local http://192.168.86.1:5000
    //web https://hidden-ridge-68133.herokuapp.com
    
//    var baseURLString: String? = nil
//    var baseURL: URL {
//        if let urlString = self.baseURLString, let url = URL(string: urlString) {
//            return url
//        } else {
//            fatalError()
//        }
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var settings: Settings = SettingsViewController().settings
        if let stripePublishableKey = UserDefaults.standard.string(forKey: "StripePublishableKey") {
            self.stripePublishableKey = stripePublishableKey
        }
        if let backendBaseURL = UserDefaults.standard.string(forKey: "StripeBackendBaseURL") {
            self.backendBaseURL = backendBaseURL
        }

        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
        Stripe.setDefaultPublishableKey(self.stripePublishableKey)
        let config = STPPaymentConfiguration.shared()

        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        let paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: settings.theme)

        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation


    }
    
    @IBAction func paybtnPressed(_ sender: Any) {
        let number = numberInput.text
        let month = monthInput.text
        let year = yearInput.text
        let cvc = cvcInput.text
        
        let session  = URLSession.shared
        let url = URL(string: backendBaseURL! + "/createToken")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let JSON = ["number":number, "month": month, "year": year, "cvc": cvc]
        let JSONDATA = try! JSONSerialization.data(withJSONObject: JSON, options: [])
        
        session.uploadTask(with: request, from: JSONDATA) {
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


