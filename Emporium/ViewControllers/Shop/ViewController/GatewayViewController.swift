//
//  GatewayViewController.swift
//  Emporium
//
//  Created by user1 on 21/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Stripe

class GatewayViewController: UIViewController {
    
    var paymentContext: STPPaymentContext? = nil
    var stripePublishableKey = "pk_test_tFCu0UObLJ3OVCTDNlrnhGSt00vtVeIOvM"
    var backendBaseURL: String? = "http://192.168.86.1:5000"
    //local http://192.168.86.1:5000
    //web https://hidden-ridge-68133.herokuapp.com
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

               var settings: Settings = SettingsViewController().settings
               if let stripePublishableKey = UserDefaults.standard.string(forKey: "StripePublishableKey") {
                   self.stripePublishableKey = stripePublishableKey
               }
               if let backendBaseURL = UserDefaults.standard.string(forKey: "StripeBackendBaseURL") {
                   self.backendBaseURL = backendBaseURL
               }
               let stripePublishableKey = self.stripePublishableKey
               let backendBaseURL = self.backendBaseURL
               
               MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
               Stripe.setDefaultPublishableKey(self.stripePublishableKey)
               let config = STPPaymentConfiguration.shared()

               let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
               let paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: settings.theme)

               let userInformation = STPUserInformation()
               paymentContext.prefilledInformation = userInformation

               self.paymentContext = paymentContext
    }
}

extension GatewayViewController: STPPaymentContextDelegate {
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    enum CheckoutError: Error {
        case unknown

        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            }
        }
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        MyAPIClient.sharedClient.createPaymentIntent() { result in
            switch result {
            case .success(let clientSecret):
                // Confirm the PaymentIntent
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.configure(with: paymentResult)
                paymentIntentParams.returnURL = "payments-example://stripe-redirect"
                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                    switch status {
                    case .succeeded:
                        // Our example backend asynchronously fulfills the customer's order via webhook
                        // See https://stripe.com/docs/payments/payment-intents/ios#fulfillment
                        completion(.success, nil)
                    case .failed:
                        completion(.error, error)
                    case .canceled:
                        completion(.userCancellation, nil)
                    @unknown default:
                        completion(.error, nil)
                    }
                }
            case .failure(let error):
                // A real app should retry this request if it was a network error.
                print("Failed to create a Payment Intent: \(error)")
                completion(.error, error)
                break
            }
        }
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "Your purchase was successful!"
        case .userCancellation:
            return()
        @unknown default:
            return()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
          
    }
    
}
