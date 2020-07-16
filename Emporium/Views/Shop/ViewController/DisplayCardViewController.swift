//
//  DisplayCardViewController.swift
//  Emporium
//
//  Created by hsienxiang on 29/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase

class DisplayCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var cardList: [Card] = []
    var cartData: [Cart] = []
    
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
        
        let cardDetail = cardList[indexPath.row]
        
        cell.nicknameLabel.text = cardDetail.nickName
        cell.expDateLabel.text = cardDetail.expMonth + "-" + cardDetail.expYear
        cell.last4Label.text = "(*" + cardDetail.last4 + ")"
        cell.brandLabel.text = cardDetail.brand
        cell.typeLabel.text = cardDetail.cardType.capitalizingFirstLetter()
        
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action:  #selector(removeClick(sender:)), for: .touchUpInside)
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        
        if cardList[indexPath.row].brand.uppercased() == "VISA" {
            cell.brandImage.image = UIImage(named: "visa")
        }else{
            cell.brandImage.image = UIImage(named: "mastercard")
        }
        
        if cardDetail.bank == "OCBC" {
            cell.brandImage.image = UIImage(named: "ocbc")
        }else if cardDetail.bank == "POSB" {
            cell.brandImage.image = UIImage(named: "posb")
        }else if cardDetail.bank == "DBS" {
            cell.brandImage.image = UIImage(named: "dbs")
        }else if cardDetail.bank == "UOB" {
            cell.brandImage.image = UIImage(named: "uob")
        }else{
            cell.brandImage.image = UIImage(named: "noImage")
        }
        
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
    
    @objc func removeClick(sender: UIButton) {
        let card = cardList[sender.tag]
        let message = "Are you sure to remove " + card.cardType.capitalizingFirstLetter() + "(*" + card.last4 + ") ?"
        let showAlert = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        let back = UIAlertAction(title: "Yes", style: .default) {
            action in
            self.removeCard(docID: card.fingerPrint)
        }
        showAlert.addAction(back)
        showAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(showAlert, animated: true, completion: nil)
    }
    
    func setUpPayment(docID: String) {
        
        self.showSpinner(onView: self.view)
        
        var paymentInfo = PaymentInfo()
        paymentInfo.cartItems = []
        
        var message = ""
        
        paymentInfo.number = docID
        paymentInfo.cvc = ""
        paymentInfo.month = 0
        paymentInfo.year = 0
        paymentInfo.bank = ""
        paymentInfo.name = ""
        paymentInfo.userid = ""
        
        for cart in cartData {
            var cartItemAdd = CartItem()
            cartItemAdd.productID = cart.productID
            cartItemAdd.quantity = Int32(cart.quantity)
            paymentInfo.cartItems.append(cartItemAdd)
        }
        
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in
        
            let data = try? paymentInfo.serializedData()
            
            let session  = URLSession.shared
            let url = URL(string: Global.BACKEND_SERVER_HOST + "/cardPayment")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
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
        })
    }
    
    func removeCard(docID: String) {
        
        self.showSpinner(onView: self.view)
    
        var message = ""
        
        Auth.auth().currentUser?.getIDToken(completion: {
            token, error in

            
            let session  = URLSession.shared
            let url = URL(string: Global.BACKEND_SERVER_HOST + "/removeCard")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let JSON = ["number":docID]
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
                            let showAlert = UIAlertController(title: "Result", message: "Card removed successfully", preferredStyle: .alert)
                            let doneBtn = UIAlertAction(title: "OK", style: .default) {
                                action in
                                self.loadCards()
                            }
                            showAlert.addAction(doneBtn)
                            self.present(showAlert, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            self.removeSpinner()
                            let showAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
