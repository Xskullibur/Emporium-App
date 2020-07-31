//
//  AddressTableViewCell.swift
//  Emporium
//
//  Created by Peh Zi Heng on 31/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    //MARK: - Variables
    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
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
