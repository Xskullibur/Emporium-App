//
//  HistoryCartCell.swift
//  Emporium
//
//  Created by user1 on 25/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class HistoryCartCell: UITableViewCell {

    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
