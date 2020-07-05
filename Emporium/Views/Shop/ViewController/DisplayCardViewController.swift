//
//  DisplayCardViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 29/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class DisplayCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var cardList: [Card] = []
    var cartData: [Cart] = []
    
    var backendBaseURL: String? = "http://192.168.86.1:5000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layer.cornerRadius = 10
        loadCards()
    }
    
    func loadCards() {
        ShopDataManager.loadCards(){
            cards in
            self.cardList = cards
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
        
        cell.layer.cornerRadius = 10
        
        cell.cardTypeLabel.text = cardList[indexPath.row].cardType.capitalizingFirstLetter() + "(*" + cardList[indexPath.row].last4 + ")"
        //cell.last4Label.text = "Last 4 digit: " + cardList[indexPath.row].last4
        cell.expDateLabel.text = cardList[indexPath.row].expMonth + "-" + cardList[indexPath.row].expYear
        
        if cardList[indexPath.row].brand.uppercased() == "VISA" {
            cell.brandImage.image = UIImage(named: "visa")
        }else{
            cell.brandImage.image = UIImage(named: "mastercard")
        }
        
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.9
        cell.layer.masksToBounds = false
        cell.clipsToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cardList[indexPath.row]
        let message = "Do you want to use " + card.cardType.capitalizingFirstLetter() + "(*" + card.last4 + ") to pay?"
        
        let showAlert = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        let back = UIAlertAction(title: "Yes", style: .default) {
            action in
            self.setUpPayment(docID: card.fingerPrint)
        }
        showAlert.addAction(back)
        showAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(showAlert, animated: true, completion: nil)
    }
    
    func setUpPayment(docID: String) {
        var paymentInfo = PaymentInfo()
        paymentInfo.cartItems = []
        
        var message = ""
        
        paymentInfo.number = docID
        paymentInfo.userid = Auth.auth().currentUser?.uid as! String
        paymentInfo.cvc = ""
        paymentInfo.month = 0
        paymentInfo.year = 0
        
        for cart in cartData {
            var cartItemAdd = CartItem()
            cartItemAdd.productID = cart.productID
            cartItemAdd.quantity = Int32(cart.quantity)
            paymentInfo.cartItems.append(cartItemAdd)
        }
        
        let data = try? paymentInfo.serializedData()
        
        let session  = URLSession.shared
        let url = URL(string: backendBaseURL! + "/cardPayment")
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
        
        
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
