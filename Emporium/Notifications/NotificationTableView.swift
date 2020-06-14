//
//  NotificationTableViewCell.swift
//  Emporium
//
//  Created by Riyfhx on 13/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class NotificationTableView: UIView {

    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    private var isSeeMore = false
    
    @IBAction func seeMorePressed(_ sender: Any) {
        isSeeMore.toggle()
        
        if isSeeMore {
            self.messageLabel.numberOfLines = 0
            self.seeMoreBtn.setTitle("See Less", for: .normal)
        }else{
            self.messageLabel.numberOfLines = 3
            self.seeMoreBtn.setTitle("See More", for: .normal)
        }
        
        self.messageLabel.layoutIfNeeded()
        
    }
    
    func setNotification(notification: EmporiumNotification){
        self.senderLabel.text = notification.sender
        self.titleLabel.text = notification.title
        self.messageLabel.text = notification.message
        self.dateLabel.text = notification.date.toBasicDateString()
    }
    
}
extension Date {
    func toBasicDateString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        return dateFormatter.string(from: self)
    }
}
