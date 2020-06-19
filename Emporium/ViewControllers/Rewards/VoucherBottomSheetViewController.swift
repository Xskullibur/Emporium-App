//
//  VoucherBottomSheetViewController.swift
//  Emporium
//
//  Created by Riyfhx on 18/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class VoucherBottomSheetViewController: UIViewController {

    @IBOutlet weak var voucherNameLabel: UILabel!
    @IBOutlet weak var voucherDescriptionLabel: UILabel!
    
    private var voucher: Voucher?
    
    private var voucherDataManager: VoucherDataManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateVoucher()
    }
    
    func setVoucher(voucher: Voucher){
        self.voucher = voucher
    }
    
    private func updateVoucher(){
        self.voucherNameLabel.text = self.voucher?.name
        self.voucherDescriptionLabel.text = self.voucher?.description
    }
    
    func setVoucherDataManager(dataManager: VoucherDataManager){
        self.voucherDataManager = dataManager
    }
    
    @IBAction func claimPressed(_ sender: Any) {
        self.voucherDataManager?.setClaimVoucher(voucher: self.voucher!, completion: nil)
        self.dismiss(animated: true)
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
