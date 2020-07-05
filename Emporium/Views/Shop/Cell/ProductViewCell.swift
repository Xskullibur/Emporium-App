//
//  ProductViewCell.swift
//  Emporium
//
//  Created by hsienxiang on 13/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards

class ProductViewCell: MDCCardCollectionCell {
    
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImageView.layer.cornerRadius = 10
    }
    
    func setCell(name: String, price: String, image: String) {
        self.nameLabel.text = name
        self.priceLabel.text = "$" + price
        if(image != "") {
            productImageView.loadImage(url: image)
        }
    }

}
