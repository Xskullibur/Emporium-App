//
//  CartCell.swift
//  Emporium
//
//  Created by hsienxiang on 15/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {
    
    
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var removeBtn: UIButton!
    
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
          frame.origin.y += 8
          frame.size.height -= 2 * 10
          frame.origin.x += 8
          frame.size.width -= 2 * 10
          super.frame = frame
      }
    }

}
