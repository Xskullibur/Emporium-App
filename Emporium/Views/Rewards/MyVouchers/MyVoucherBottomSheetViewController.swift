//
//  VoucherBottomSheetViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 18/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class MyVoucherBottomSheetViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var voucherNameLabel: UILabel!
    @IBOutlet weak var voucherDescriptionLabel: UILabel!
    
    // MARK: - Variables
    private var voucher: Voucher?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateVoucher()
    }
    
    /**
     Set Voucher to be displayed
     */
    func setVoucher(voucher: Voucher){
        self.voucher = voucher
    }
    
    /**
     Display the voucher
     */
    private func updateVoucher(){
        self.voucherNameLabel.text = self.voucher?.name
        self.voucherDescriptionLabel.text = self.voucher?.description
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
