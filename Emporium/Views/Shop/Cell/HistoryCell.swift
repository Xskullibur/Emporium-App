//
//  HistoryCell.swift
//  Emporium
//
//  Created by user1 on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
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


