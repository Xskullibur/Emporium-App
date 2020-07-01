//
//  VoucherTableViewCell.swift
//  Emporium
//
//  Created by Peh Zi Heng on 18/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class MyVoucherTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var voucherNameLabel: UILabel!
    @IBOutlet weak var voucherDescriptionLabel: UILabel!
    
    // MARK: - Variables
    private var voucher: Voucher?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /**
     Set the voucher to be displayed
     */
    func setVoucher(voucher: Voucher){
        self.voucher = voucher
        self.voucherNameLabel.text = voucher.name
        self.voucherDescriptionLabel.text = voucher.description
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
