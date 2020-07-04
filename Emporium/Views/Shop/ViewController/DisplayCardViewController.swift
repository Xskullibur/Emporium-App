//
//  DisplayCardViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 29/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class DisplayCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var cardList: [Card] = []
    
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
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
