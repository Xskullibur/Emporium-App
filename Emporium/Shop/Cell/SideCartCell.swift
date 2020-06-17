//
//  SideCartCell.swift
//  Emporium
//
//  Created by user1 on 16/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards

class SideCartCell: MDCCardCollectionCell  {
    
    
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var cartName: UILabel!
    @IBOutlet weak var cartQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cartImage.layer.cornerRadius = 10
    }
    
    func setCell(_ name: String, _ quantity: Int, _ image: String) {
        self.cartName.text = name
        self.cartQuantity.text = String(quantity) + "X"
        self.cartImage.image = UIImage(named: image)
    }
    
}
