//
//  AddressCell.swift
//  Emporium
//
//  Created by user1 on 15/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {

     @IBOutlet weak var addressNameLabel: UILabel!
     @IBOutlet weak var addressLabel: UILabel!
     @IBOutlet weak var editBtn: UIButton!
    
       //MARK: - Lifecycle
       override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }
       
       /**
        Set the address to be displayed on the cell
        */
       func setAddress(_ address: Address){
           addressNameLabel.text = address.name
           addressLabel.text = address.address
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }

}
