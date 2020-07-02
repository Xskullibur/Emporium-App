//
//  CardCell.swift
//  Emporium
//
//  Created by user1 on 2/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {
    
    
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var cardTypeLabel: UILabel!
    @IBOutlet weak var last4Label: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
      get {
          return super.frame
      }
      set (newFrame) {
          var frame =  newFrame
          frame.origin.y += 4
          frame.size.height -= 2 * 10
          frame.origin.x += 4
          frame.size.width -= 2 * 5
          super.frame = frame
      }
    }

}
